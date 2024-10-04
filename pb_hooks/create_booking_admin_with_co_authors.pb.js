routerAdd("POST", "/api/shc/admin_make_a_booking_with_co_authors/:dateISOstart/:dateISOend/:accountID", (c) => {
    let start_time = c.pathParam("dateISOstart")
    let end_time = c.pathParam("dateISOend")
    let accountID = c.pathParam("accountID")
    let coAuthors = $apis.requestInfo(c).data.coAuthors

    let authRecordPermissions = c.get("authRecord").getString("permissions")
    let permissionsRecord = $app.dao().findRecordById("permissions", authRecordPermissions)

    if (!permissionsRecord.getBool("allowed_to_enter_coaches_ui")) {
	throw new UnauthorizedError("admins only", "your account isn't auhtorised for this")
}

    //if (!$apis.requestInfo(c).admin) {
      //  throw new UnauthorizedError("admins only", "You need to log in with an admin account to make a booking with this API")
    //}

    $app.logger().info("creating a booking - admin",
        "user", accountID,
        "coAuthorEmails", coAuthors
    )
    let coAuthorsIDs = []

    for (let i = 0; i < coAuthors.length; i++) {
     console.log(`email = '${coAuthors[i]}'`)
       let record = $app.dao().findFirstRecordByFilter(
    "users", `email = '${coAuthors[i]}'`,
)
        coAuthorsIDs.push(record.getString("id"))
console.log(coAuthorsIDs)
}


    const bookings_collection = $app.dao().findCollectionByNameOrId("bookings")
    const record = new Record(bookings_collection)

    const form = new RecordUpsertForm($app, record)

    form.loadData({
        "booker": [accountID, ...coAuthorsIDs],
        "start_time": start_time,
        "end_time": end_time,
        "cost": 0
    })
    try {
        form.submit();
    } catch (e) {
    throw new BadRequestError("Can't book", e.toString())
    }
    return c.noContent(204)
}, $apis.activityLogger($app))
