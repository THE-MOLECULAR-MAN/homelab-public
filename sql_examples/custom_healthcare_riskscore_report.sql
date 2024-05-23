-- This SQL query was written by Tim for a presales prospect
-- who needed to implement their own custom risk score to assess
-- vulnerabilities in their environment.
-- It is designed to be run as a custom report in Rapid7 InsightVM (Nexpose) 
-- and export as a CSV file (at their request).
-- 
-- Data Warehouse Schema for reference: https://help.rapid7.com/nexpose/en-us/warehouse/warehouse-schema.html
-- Operational Database Schema: https://docs.rapid7.com/insightvm/understanding-the-reporting-data-model-overview-and-query-design/

WITH vuln_references AS
(
          SELECT    dv.vulnerability_id,
                    Round(dv.cvss_score::numeric, 1) AS vuln_cvss,
                    dv.severity                      AS vuln_severity,
                    dv.title                         AS vuln_name,
                    dv.description,
                    dv.exploits                                                                        AS exploitability,
                    array_to_string(Array_agg(dvr.reference) filter (WHERE dvr.source = 'CVE'), ', ')  AS cves,
                    array_to_string(array_agg(dvr.reference) filter (WHERE dvr.source <> 'CVE'), ', ') AS other_references
          FROM      dim_vulnerability_reference dvr
          LEFT JOIN dim_vulnerability dv
          ON        (
                              dv.vulnerability_id = dvr.vulnerability_id)
          GROUP BY  dv.vulnerability_id,
                    dv.cvss_score,
                    dv.severity,
                    dv.title,
                    dv.description,
                    dv.exploits ), netbios_assets AS
(
       SELECT dahn.asset_id,
              dahn.host_name
       FROM   dim_asset_host_name dahn
       WHERE  source_type_id = 'N' ), asset_tags AS
(
          SELECT    da.asset_id,
                    da.host_name,
                    da.ip_address,
                    na.host_name                                  AS netbios_name,
                    array_to_string(array_agg(dt.tag_name), ', ') AS asset_tags
          FROM      dim_asset da
          LEFT JOIN dim_tag_asset dta
          ON        (
                              dta.asset_id = da.asset_id)
          LEFT JOIN dim_tag dt
          ON        (
                              dt.tag_id = dta.tag_id)
          LEFT JOIN netbios_assets na
          ON        (
                              da.asset_id = na.asset_id)
          GROUP BY  da.asset_id,
                    da.host_name,
                    da.ip_address,
                    na.host_name ), asset_vulnerability_solution AS
(
       SELECT davbs.asset_id,
              davbs.vulnerability_id,
              davbs.solution_id,
              ds.fix AS vuln_solution
       FROM   dim_asset_vulnerability_best_solution davbs
       JOIN   dim_solution ds
       ON     (
                     davbs.solution_id = ds.solution_id) ), exploit_method AS
(
          SELECT    dcav.type_id,
                    dcav.description
          FROM      dim_cvss_access_vector dcav
          LEFT JOIN dim_vulnerability
          ON        (
                              dim_vulnerability.cvss_access_vector_id = dcav.type_id) )
SELECT    favi.vulnerability_id AS pluginid,
          vr.cves,
          vr.vuln_cvss,
          em.type_id,
          em.description,
          at.asset_tags,
          vr.vuln_cvss +
          --case
          --   when vr.exploits == 0 then 1 -- no exploits available, so no need to look up if they are local/remote
          --   when em.description == 'L' then 3
          --   when em.description == 'A' then 5
          --   when em.description == 'N' then 5
          --   else 1
          --end +
          CASE
                    WHEN at.asset_tags LIKE '%HV0%' THEN 5
                    WHEN at.asset_tags LIKE '%HV1%' THEN 4
                    WHEN at.asset_tags LIKE '%HV2%' THEN 3
                    WHEN at.asset_tags LIKE '%HV3%' THEN 2
                    WHEN at.asset_tags LIKE '%HV4%' THEN 1
                    ELSE 0
                              -- could be a case where not tagged with HV or it is tagged with multiple HVs and need to make the max
                              -- Microsoft SQL does short-circuiting with case when statements, unclear about PSQL. This syntax should solve the multiple tag problem and use the highest one if PSQL does short-circuiting
          END AS prospect_custom_risk,
          vr.vuln_severity,
          at.host_name  AS host,
          at.ip_address AS ip_address,
          at.netbios_name,
          at.asset_id,
          dp.NAME AS protocol,
          CASE
                    WHEN favi.port = -1 THEN NULL
                    ELSE favi.port
          END AS ports,
          vr.vuln_name,
          proofastext(vr.description)    AS vuln_synopsis,
          proofastext(vr.description)    AS vuln_description,
          proofastext(avs.vuln_solution) AS solution,
          vr.other_references            AS see_also_additional_resources,
          proofastext(favi.proof)        AS plugin_output_proof,
          vr.exploitability,
          -- asset tags normally goes here
          -1 AS assigned_asset_category,
          -- custom risk column goes here   prospect_custom_risk,
          -1 AS calculated_priority,
          -1 AS remediation_assignee,
          -1 AS fields_for_query
FROM      fact_asset_vulnerability_instance favi
JOIN      asset_tags at
ON        (
                    at.asset_id = favi.asset_id)
JOIN      vuln_references vr
ON        (
                    vr.vulnerability_id = favi.vulnerability_id)
JOIN      asset_vulnerability_solution avs
ON        (
                    favi.asset_id = avs.asset_id
          AND       favi.vulnerability_id = avs.vulnerability_id)
JOIN      dim_protocol dp
using     (protocol_id)
LEFT JOIN exploit_method em
ON        (
                    dim_vulnerability.cvss_access_vector_id = em.type_id)
LEFT JOIN dim_service dsvc
using     (service_id)