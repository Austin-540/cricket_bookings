routerAdd("POST", "/api/shc/topup/getdetails", (c) => {
    const code = $apis.requestInfo(c).data.data
    console.log(code)

    $app.logger().info("New Topup code check:", code)
    var start = new Date().getTime();
    while(new Date().getTime() < start + 300) {}

    const hash = $security.sha256(code)

    $app.logger().info("Looking for topup code with hash", {"hash": hash})

    const record = $app.dao().findFirstRecordByFilter(
        "topup_codes", "code = {:code}",
        { code: `${hash}` },
    )

    return c.json(200, { 
        "valid": true,
        "value": record.getInt("amount"),
        "redeemed": record.getBool("redeemed")

     })
}, /* optional middlewares */)

routerAdd("POST", "/api/shc/topup/usecode/:userID", (c) => {
    const code = $apis.requestInfo(c).data.data
    let userID = c.pathParam("userID")

    var start = new Date().getTime();
    while(new Date().getTime() < start + 700) {}

    const code_record = $app.dao().findFirstRecordByFilter(
        "topup_codes", "code = {:code}",
        { code: `${$security.sha256(code)}` },
    )

    const topup_amount = code_record.getInt("amount")

    const redeemed = code_record.getBool("redeemed")

    if (redeemed) {
        throw new ForbiddenError("Not allowed", "This code has already been used")
    }

    const user_record = $app.dao().findRecordById("users", userID)


    const balance = user_record.getInt("balance")
    const new_balance = balance + topup_amount

    user_record.set("balance", new_balance)
    $app.dao().saveRecord(user_record)

    code_record.set("redeemed", true)
    $app.dao().saveRecord(code_record)

    code_record.set("redeemed_by", userID)
    $app.dao().saveRecord(code_record)

    $app.logger().info(
        "Account topup",
        "account id", userID,
        "amount", topup_amount,
        "code", code
    )

    return c.json(200, { 
        "success": true,
     })
}, /* optional middlewares */)
