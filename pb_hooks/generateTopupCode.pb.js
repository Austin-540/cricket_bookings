routerAdd("POST", "/api/shc/admin/make_new_topup_code", (c) => {
    const amount = $apis.requestInfo(c).data.data
    const collection = $app.dao().findCollectionByNameOrId("topup_codes")
    const code = $security.randomString(13).toUpperCase()
    const hash = $security.sha256(code)

    const record = new Record(collection, {
        "code": hash,
        "redeemed": false,
        "amount": amount
    })

    $app.dao().saveRecord(record)


    function checksum(s) {
        var chk = 0x12345678;
          var len = s.length;
      for (var i =0; i <len; i++) {
        chk += (s.charCodeAt(i) * (i+1));
      }
      return (chk & 0xffffffff).toString(16);
      }

    const full_code = code + checksum(code).toUpperCase().slice(-3)


    return c.json(200, { "code": full_code})
}, $apis.requireAdminAuth(), $apis.activityLogger($app))