#!/bin/bash
# Tim H 2023

# https://kb.vmware.com/s/article/80469

# CLI tool for diagnosing and fixing vSphere issues
# should be run while in SSH session on the vSphere VM

# Had to do this stuff so I could migrate a vSphere 7 to 8

# all of the changes I made, not all listed here, seemed to fix it
# make sure NTP service is running and set to autostart, and is working
# I also manually deleted a few plugins like this: https://kb.vmware.com/s/article/1025360
# I removed the CyberPower one and a few others that were causing issues

# These 3 warnings remained on my last run but didn't cause any issues:
# Files that cannot be used with Lifecycle Manager 8.0.0 will not be copied from the source. These files
# include VM guest OS patch baselines, host upgrade baselines and files, and ESXi 6.5 and lower version
# host patches baselines.
#
#This ESXi host (//10.0.1.27:443] is managed by Center Server (10.0.1.31].
# Make sure the cluster where this ESXi host resides is not set to Fully Automated DRS for the duration of
# the upgrade process.

# Integrated Windows Authentication is deprecated. Learn more


mkdir ~/lsdoctor
cd ~/lsdoctor || exit 1
curl --output lsdoctor.zip 'https://kb.vmware.com/sfc/servlet.shepherd/version/download/0685G0000156OnnQAE' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: https://kb.vmware.com/s/article/80469' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Cookie: _abck=627AC31C377B650F555B356EFE83DB96~0~YAAQl77CF8BdREmGAQAAJMfhUwnI2iFge6JTsig9fGpdN3r0ip2pIP4xE/WA+vh7TugetjtoE254ldE93n4m1/pkfBkjcgz4g8GxwLWBq/qTeqQwfbynGh7TrKya/oJAh5aRmJGxRGNJpGtsY2FpDNvflxLdwDVkXpt8LAcnBXUnqL9tSt6Irhyov7cVQ8DFQEIQjYv6r5sNfqocoO8ZT5is9ADQzNAvdcvsVfsLvrFaNpSm5VEN8VZG+p5YABlMJqcHtf+XlWEcRly7rmYb7W3XraK4sjnZg3dZxgDlwRv342L952yMoZftNI85U/fX1FkFTpaG/HgEY3udi+1qNy55UYaaCQ4tqCKUaBvHRIKgfIB5YIOIN6JBtRPfSZdea/Sj5kFcvIu7U0zQ3X1I9OMWgeuASfnrxg==~-1~-1~-1; OptanonConsent=isGpcEnabled=0&datestamp=Wed+Feb+15+2023+02%3A00%3A08+GMT-0500+(Eastern+Standard+Time)&version=202301.1.0&isIABGlobal=false&hosts=&consentId=2a9550c0-fccd-4ee7-9db0-ce6ff0aaa249&interactionCount=1&landingPath=NotLandingPage&groups=C0001%3A1%2CC0002%3A1%2CC0003%3A1%2CC0004%3A1%2CC0005%3A1&AwaitingReconsent=false; AMCV_5B29123F5245AD520A490D45%40AdobeOrg=-1124106680%7CMCIDTS%7C19404%7CMCMID%7C22635916653605267647228917542911400837%7CMCOPTOUT-1676451908s%7CNONE%7CvVersion%7C5.2.0; utag_main=v_id:01829cbcfaba00216fda2208294405054002f00f00942$_sn:9$_ss:0$_st:1676446347666$ses_id:1676442577572%3Bexp-session$_pn:7%3Bexp-session; pszGeoPref=us; CookieConsentPolicy=0:1; LSKey-c$CookieConsentPolicy=0:1; pctrk=c69fc6fc-2f06-492c-9b6a-71929bf886f0; _gcl_au=1.1.1467338864.1675011117; _uetvid=3e1f1d609ff511eda77a1d6679beb668; dtCookie=v_4_srv_2_sn_B638530E0D91376ADBB5DBBAEB649CB1_perc_100000_ol_0_mul_1_app-3A40cb821d091f8001_1_app-3Ada9697f3ebf33458_1; dtPC=2$438435336_235h-vSPQUPAIVTGRWSQQGQLEKCIFOOCMCFEBS-0; rxvt=1675040237032|1675036333540; dtSa=false%7C_load_%7C23%7C_onload_%7C-%7C1675038437032%7C438435336_235%7Chttps%3A%2F%2Fcustomerconnect.vmware.com%2Fhome%3Fbmctx%3D89E60DF848C641FD518EB9F6B9A6E5334F602FA3A762B409625CD531863AC847%26password%3Dsecure_5Fstring%26contextType%3Dexternal%26username%3Dstring%26challenge_5Furl%3Dhttps%3A_252F_252Fcustomerconnect.vmware.com_252Fhome%26request_5Fid%3D-7576985890442877340%26authn_5Ftry_5Fcount%3D0%26locale%3Den_5FUS%26resource_5Furl%3Dhttps_25253A_25252F_25252Fcustomerconnect.vmware.com_25252Fweb_25252Fvmware_25252Fchecksession%7CVMware%20Customer%20Connect%20%5Ep%20Get%20Personalized%20Support%20Quickly%20and%20Easily%20%5Ep%20VMware%20Support%7C%7C%7C; dtLatC=1082; at_check=true; AMCVS_5B29123F5245AD520A490D45%40AdobeOrg=1; s_sq=vmwareglobal%3D%2526c.%2526a.%2526activitymap.%2526page%253Dhttps%25253A%25252F%25252Fkb.vmware.com%25252Fs%25252Farticle%25252F80469%2526link%253Dlsdoctor%2526region%253Dattachments_list%2526.activitymap%2526.a%2526.c; LSKey-c$coveo_visitorId=392dea44-235d-4a90-86fa-ed0801a8eedc; s_dse=https%3A%2F%2Fwww.google.com%2F%3Avmware%20%3A%20customerconnect%20%3A%20web%20%3A%20evals%20%3A%20evaluate-vsphere-eval%20%3A%20guest%20%3A%20install%3AGoogle%3ANatural%20Search; s_ppv=vmware%2520%253A%2520customerconnect%2520%253A%2520downloads%2520%253A%2520VMware%2520vSphere%2520%253A%25208.0%2520%253A%2520OEM-ESXI80-HPE%2C100%2C100%2C702; s_tp=702; s_cc=true; OAMAuthnHintCookie=0@1675039368; ev6=hypervisor; rxVisitor=1648845339207P5PN8016090FJ61A3CKJNRL56UKHT9F6; ak_bmsc=6114527556F0EE8F82A49870CE080072~000000000000000000000000000000~YAAQlLxuaIXooFGGAQAAxZXfUxLf7pRLOfOhrj1De1fxO/co90JRxXDOX2GVoCp32W9H6yJ5iWeiFRx3RXOvTXfs2CBm/ZEjIfCsNj3vKSX2A135zDU3uYruPM4/tYaNBlVEC0Q/DhltlrZwMdao+FVwoKTjOcHC+ryXB507p3mi/Y0yLhdXh3ZnlFTCm6pRglNGfosyZlQ4c/jYTIOY1QQFqDxLpJYOITZEB1V/M/zzj1y7QsF8BkkCNVmufxhr7XChycK6N4IOLRZ/NsIUbMt5BMptmXc6rVOUMoy4/NSwOzw+BkdZhUqeL0rO7o/Ng/FZciGuEoOr22lBP8Kn4R1997HPLTRQTXZcUp2o/Hppc7z9e2vMQMb1Rk5zPCJ/4S0evGtRAL4UY4/qxSY0566dAzOGy5gepd7ilYFNDWF9by0v; bm_sz=0964422FE4253F7EB25274C0EE288353~YAAQLZQZuM29kEyGAQAAAqrDUxIyCyeYdEZYZQq91SKEJrB00AqcR4uDQ2v06lPRFO7TWJKx9Vmg5fNJTxq2rFwJIaHVxz4S4twUGhafdh0U2OPANdrN+/AjwkXRzmRh6gzoSi790yciSAnXsjXEYCYAMf00XBoL7Azp5cLytT/i78QCU2dUf7EetzB0sPUqRxtJFcIDDRJU0sJDxLuxArgzwD49SnPcM9S9JVWO45Pko3Vh3p7dduFLI3p3rHIqMFmCv0C7/aATZ8tl9LcNRIMeFv20xkzrDvr7cHfRO/t9pUA=~4404279~4601653; sfdc-stream=!GbvWGR277IHoMAFXMxq6xUfFn4Dj31O0fhppUPxPANDZTnE1cLGiP20gms8x0DZuHdi33sv6gvnFi6A=; force-proxy-stream=!oBlq6i1RgSes/FqM8hqBCQEkycNPzjJuX7l9ZTqb94PZJRyNN1LxGRKU6D8SLa2oeWNeqB/fImCi6zA=; force-stream=!GbvWGR277IHoMAFXMxq6xUfFn4Dj31O0fhppUPxPANDZTnE1cLGiP20gms8x0DZuHdi33sv6gvnFi6A=; bm_sv=3696BD11A30A441FBC1551761BD2C42F~YAAQlLxuaLvnoFGGAQAAeFjfUxK76G6tHIAbfeq9S8dybKQiBJGXggvudZiGQcZZ33RLJfpdaUkVBU/wrWpC+qBlGay7ek1cVpLpkcZ51oWdahaA0dyiL90UFs02r1DClGjUZE1XnBnrpmeA4N9WSBXN8QK7zpCAL2+XLn1UGEikR/ExxhVuj//RiEWde3cdstyMKkg4Gl20Cs3Kbxst54KdctbMUI3zTsITx9gjBjQ8mq7wSP6VuHcaO1vFE7QS/A==~1; bm_mi=91A2784335D991DE6B996A2AB9575F66~YAAQlLxuaJTnoFGGAQAAJE7fUxJ53YQdfFfvh4b3mUWtBR41GDVNCs5Ia4ndhjbacEvfomrAhkSdvCmpLr8WvBoCNqUXDH7WmdktQSrDFOblRiHI+QMBjX1Iqk5MhakhFAZpobhNIA/lyWxj8da0bYbb0CmwD8yf5t2NktvQOcSu32nvFyAG7o6jCwot31gGuSm1VjKqN/6BNj8n6HA35d1aJrQIKXWNMGDQIEN6eifl9g1C3ZDEa3IcUl/9ixyyowCYq8ayqeS6Ceb2GSz8pNqqe/hm5iY6Rldw9lDJCDwqcWM/wO7Up5B/RFbVW2ujNzvTLWNS6bXBCVig~1' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers'
unzip lsdoctor.zip

cd lsdoctor-master || exit 2
python lsdoctor.py --help

# 2023-02-15T02:07:38 ERROR generateReport: default-site\vsphere.int.butters.me (VC 7.0 or CGW) found Duplicates Found: Ignore if this is the PSC HA VIP.  Otherwise, you must unregister the extra endpoints.
# 2023-02-15T02:07:38 INFO generateReport: Report generated:  /var/log/vmware/lsdoctor/vsphere.int.butters.me-2023-02-15-020738.json

# cat /var/log/vmware/lsdoctor/*.json

python lsdoctor.py --stalefix
python lsdoctor.py --trustfix

# this can wreck things:
# I tried this:         2.  Replace all services with new services.
# You have selected a Rebuild function.  This is a potentially destructive operation!
# All external solutions and 3rd party plugins that register with the lookup service may
# have to be re-registered.  For example: SRM, vSphere Replication, NSX Manager, etc.

# this takes several minutes to run:
# this fixed the duplicate service names issue and removed some unused plugins
python lsdoctor.py --rebuild

# unrelated thing that needed to be changed too:
# https://kb.vmware.com/s/article/71083
/opt/likewise/bin/domainjoin-cli leave
# gotta also delete the AD listing in the GUI
reboot now && logout
