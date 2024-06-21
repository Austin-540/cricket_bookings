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
        "-start_time",                                   // sort
        9990,                                            // limit
        0                                             // offse                          // optional filter params
    )

    let month_booked_slots = []

        //Only show the timeslots from this month
    for (const booked_slot of all_booked_slots) {
        console.log(`Looking for: ${booked_slot.getDateTime("start_time").time().month()} == ${month} ___ time: ${booked_slot.getDateTime("start_time").time().day()}`)
        if (booked_slot.getDateTime("start_time").time().month().string() == month && booked_slot.getDateTime("start_time").time().year() == year) {
           month_booked_slots.push(booked_slot)
            console.log(JSON.stringify(booked_slot))
            console.log("Found")
        } else {
            console.log("Not found")
        }

    }

    //now filter sort them into days
    let slotsMap = {};

    for (const slot of month_booked_slots) {
        var relevantPartOfSlotsMap = slotsMap[`${slot.getDateTime("start_time").time().day()}`]
        console.log(JSON.stringify(relevantPartOfSlotsMap))
        if (slotsMap[`${slot.getDateTime("start_time").time().day()}`] != undefined) {
            slotsMap[`${slot.getDateTime("start_time").time().day()}`] = [...relevantPartOfSlotsMap, slot]
        } else {
            slotsMap[`${slot.getDateTime("start_time").time().day()}`] = [slot]
        }
    }
    


    

    
    return c.json(200, { "slots": month_booked_slots, "map":slotsMap },)

}, $apis.activityLogger($app))
