routerAdd("GET", "/api/shc/gettimeslots/:day/:month/:year", (c) => {

    const months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let day = c.pathParam("day")
    let monthNum = c.pathParam("month")
    let month = months[monthNum - 1]
    let year = c.pathParam("year")
    console.log("Looking for:" + day + " " + month + " " + year)
    const timeslots_list = $app.dao().findRecordsByFilter(
        "timeslots",                                    // collection
        "start_time != 90876854", // filter
        "-created",                                   // sort
        250,                                            // limit
        0,                                             // offset                         // optional filter params
    )

    console.log("filering by: " )
    console.log(`year = ${year} && month = ${monthNum} && day = ${day}`)

    const day_booked_slots_db = $app.dao().findRecordsByFilter(
        "bookings",                                    // collection
        `year = ${year} && month = ${monthNum} && day = ${day}`, // filter
        "-created",                                   // sort
        999,                                            // limit
        0                                             // offse                          // optional filter params
    )

    const day_booked_slots = []
    for (var element of day_booked_slots_db) {
        day_booked_slots.push(element.getInt("hour"))
    }



    let final_list = []
    for (const element of timeslots_list) {
        if (element.getString("am_or_pm") === "PM") {
            element.set("start_time", element.getInt("start_time") + 12)
        }
        console.log("running for loop...")
        console.log("looking for " + element.getInt("start_time") + "in " + day_booked_slots.toString())
        if (day_booked_slots.includes(element.getInt("start_time"))) {
            final_list.push({
                "start_time": element.getInt("start_time"),
                "end_time": element.getInt("start_time") + 1,
                "booked": true,
                "am_or_pm": element.getInt("hour") >= 12? "PM": "AM"
            })

        } else {
            console.log("running else...")
            final_list.push({
                "start_time": element.getInt("start_time"),
                "booked": false,
            })
        }
    }


    return c.json(200, { "slots": final_list },)

}, $apis.activityLogger($app))
