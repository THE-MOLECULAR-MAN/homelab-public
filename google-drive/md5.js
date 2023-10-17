function MD5 (input) {
    var rawHash = Utilities.computeDigest(Utilities.DigestAlgorithm.MD5, String(input));
    var txtHash = "";
    var i;
    var hashVal;
  
    for (i = 0; i < rawHash.length; i+= 1) {
      hashVal = rawHash[i];
      if (hashVal < 0) {
        hashVal += 256;
      }
      if (hashVal.toString(16).length === 1) {
        txtHash += "0";
      }
      txtHash += hashVal.toString(16);
    }
    return txtHash;
  }