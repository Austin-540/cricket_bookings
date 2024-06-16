routerAdd("GET", "/api/shc/cancelbooking/:bookingid", (c) => {
    const authed_user_record = c.get('authRecord')

        if (authed_user_record === null) {
                throw new UnauthorizedError("No account", "You need to log in before doing this")
}

    let bookingID = c.pathParam("bookingid")

    const record = $app.dao().findRecordById("bookings", bookingID)

    $app.logger().info("Request to delete a booking", "booking id", bookingID)

    const cost = record.get("cost");
    const userID = record.getString("booker")

        if (authed_user_record.id !== userID) {
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



    return c.json(200, { "message": 'deleted' })
}, $apis.activityLogger($app))