routerAdd("GET", "/api/shc/gettimeslotsmonth/:month/:year", (c) => {

    const months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let monthNum = c.pathParam("month")
    let month = months[monthNum - 1]
    let year = c.pathParam("year")
    console.log("Looking for:" + " " + month + " " + year)
    const timeslots_list = $app.dao().findRecordsByFilter(
        "timeslots",                                    // collection
        "am_or_pm != 'iurwghur5ehreiu5ih98hiuhsk'", // filter
        "-created",                                   // sort
        250,                                            // limit
        0,                                             // offset                         // optional filter params
    )

    const all_booked_slots = $app.dao().findRecordsByFilter(
        "bookings",                                    // collection
        "finished = false", // filter
        "-created",                                   // sort
        9990,                                            // limit
        0                                             // offse                          // optional filter params
    )

    let month_booked_slots = []

   


    let final_list = {
        1: [],
        2: [],
        3: [],
        4: [],
        5: [],
        6: [],
        7: [],
        8: [],
        9: [],
        10: [],
        11: [],
        12: [],
        13: [],
        14: [],
        15: [],
        16: [],
        17: [],
        18: [],
        19: [],
        20: [],
        21: [],
        22: [],
        23: [],
        24: [],
        25: [],
        26: [],
        27: [],
        28: [],
        29: [],
        30: [],
        31: []
    }

    for (const booked_slot of all_booked_slots) {
        console.log(`Looking for: ${booked_slot.getDateTime("start_time").time().month()} == ${month} ___ time: ${booked_slot.getDateTime("start_time").time().day()}`)
        if (booked_slot.getDateTime("start_time").time().month().string() == month) {
            let finalListCurrent = final_list[booked_slot.getDateTime("start_time").time().day()]
            final_list[booked_slot.getDateTime("start_time").time().day()] = finalListCurrent.push(booked_slot)
            console.log(JSON.stringify(booked_slot))
            console.log("Found")
        } else {
            console.log("Not found")
        }

    }
    
    // for (const element of timeslots_list) {
    //     if (element.getString("am_or_pm") === "PM") {
    //         element.set("start_time", element.getInt("start_time") + 12)
    //     }
    //     console.log("running for loop...")
    //     console.log("looking for " + element.getInt("start_time") + "in " + month_booked_slots.toString())
    //     if (month_booked_slots.includes(element.getInt("start_time"))) {
    //         final_list.push({
    //             "start_time": element.getInt("start_time"),
    //             "end_time": element.getInt("end_time"),
    //             "booked": true,
    //             "am_or_pm": element.getString("am_or_pm")
    //         })

    //     } else {
    //         console.log("running else...")
    //         final_list.push({
    //             "start_time": element.getInt("start_time"),
    //             "end_time": element.getInt("end_time"),
    //             "booked": false,
    //             "am_or_pm": element.getString("am_or_pm")
    //         })
    //     }
    // }
    // let final_final_list = []
    // for (let element of final_list) {
    //     if (element.start_time > 12) {
    //         element.start_time = element.start_time - 12
    //         }
    //     final_final_list.push(element)
    // }


    return c.json(200, { "slots": final_list },)

}, $apis.activityLogger($app))