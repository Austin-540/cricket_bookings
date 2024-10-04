routerAdd("GET", "/api/shc/cancelbooking/:bookingid", (c) => {
    const authed_user_record = c.get('authRecord')

	if (authed_user_record === null) {
		throw new UnauthorizedError("No account", "You need to log in before doing this")
}

    let bookingID = c.pathParam("bookingid")

    const record = $app.dao().findFirstRecordByFilter(
        'bookings', `id = '${bookingID}' && booker ~ '${authed_user_record.id}'`
    )
    $app.logger().info("Request to delete a booking", "booking id", bookingID)

    const cost = record.get("cost");
    const userID = record.getStringSlice("booker")

    console.log("userID: " + userID)

	if (false) {
        console.log("authed_user_record.id: " + authed_user_record.id)
        console.log("userID: " + userID)
	throw new UnauthorizedError("This account doesn't own that booking", "You can't cancel someone else's booking.")
}

    const user_record = $app.dao().findRecordById("users", userID)
    const current_balance = user_record.getFloat("balance")

    $app.logger().info("Deleting a booking and issuing refund",
        "accountID", userID,
        "refund amount", cost,
        "authRecord", JSON.stringify(authed_user_record)
    )

    

    $app.dao().runInTransaction(
        (txDao) => {
            user_record.set("balance", current_balance + cost)
            txDao.saveRecord(user_record)

            txDao.deleteRecord(record)
        }
    )



    const message = new MailerMessage({
        from: {
            address: $app.settings().meta.senderAddress,
            name:    $app.settings().meta.senderName,
        },
        to:      [{address: user_record.email()}],
        subject: `[SHC Cricket] Booking Cancelled - ${record.getString("start_time")}`,
        html:    "Your booking was cancelled.",
    })

    $app.newMailClient().send(message)


    return c.json(200, { "message": 'deleted' })
},$apis.activityLogger($app))
