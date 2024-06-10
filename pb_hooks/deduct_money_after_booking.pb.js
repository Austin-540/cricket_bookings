onRecordAfterCreateRequest((e) => {
    try {

    
    const record = e.record
    const user_record = $app.dao().findRecordById("users", record.getString("booker"))

  

    const balance = user_record.getInt("balance")

    const permissions = user_record.getString("permissions")

    $app.logger().info("creating a booking",
        "user", record.getString("booker"),
        "permissions", permissions,
        "balance", balance
    )

    const price_record = $app.dao().findFirstRecordByFilter(
        "prices", `account_type = '${permissions}'`,
    )

    const price = price_record.getInt("price")

    if (price > balance) {
        throw new ForbiddenError("Balance too low", "You need to top up to make this booking")
    }

    
    user_record.set("balance", balance-price)
    $app.dao().saveRecord(user_record)
} catch (x) {
    $app.logger().error(x)
    $app.dao().deleteRecord(e.record)
    $app.logger().info("Deleted a booking due to error")
    throw new ForbiddenError("Something went wrong while booking", "The record couldn't be created")
}
}, "bookings")

