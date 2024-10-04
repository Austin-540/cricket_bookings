routerAdd("POST", "/api/shc/make_a_booking/:year/:month/:day/:hour", (c) => {
    console.log("creating a booking")
    let year = c.pathParam("year")
    let month = c.pathParam("month")
    let day = c.pathParam("day")
    let hour = c.pathParam("hour")

    if (!$apis.requestInfo(c).authRecord) {
        throw new UnauthorizedError("You aren't logged in", "You need to log in to make a booking")
    }

    const user_record = $apis.requestInfo(c).authRecord;
    const balance = user_record.getInt("balance")

    const permissions = user_record.getString("permissions")
    $app.logger().info("creating a booking",
        "user", user_record.getString("id"),
        "permissions", permissions,
        "balance", balance
    )

    const price_record = $app.dao().findFirstRecordByFilter(
        "prices", `account_type = '${permissions}'`,
    )
    console.log("got price")

    const price = price_record.getInt("price")

    if (price > balance) {
        throw new ForbiddenError("Balance too low", "You need to top up to make this booking")
    }

    user_record.set("balance", balance-price)
    $app.dao().saveRecord(user_record)


    const bookings_collection = $app.dao().findCollectionByNameOrId("bookings");
    const record = new Record(bookings_collection)

    const form = new RecordUpsertForm($app, record)

    form.loadData({
        "booker": user_record.getString("id"),
        "cost": price,
        "year": year,
        "month": month,
        "day": day,
        "hour": hour
    })
    try {
        form.submit();
    } catch (e) {
    user_record.set("balance", balance)
    $app.dao().saveRecord(user_record)
    throw new BadRequestError("Can't book", e.toString())
    }

    const message = new MailerMessage({
        from: {
            address: $app.settings().meta.senderAddress,
            name:    $app.settings().meta.senderName,
        },
        to:      [{address: user_record.email()}],
        subject: "You made a booking",
        html:    `Your door code is: ${parseInt($security.md5(record.id), 36).toString().replace("e+", "").slice(-10, -4)}`,
        // bcc, cc and custom headers are also supported...
    })

    $app.newMailClient().send(message)



    return c.noContent(204)
}, /* optional middlewares */)
