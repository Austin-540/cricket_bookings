routerAdd("GET", "/api/shc/rfid_registration/:card_number/:card_holder_name", (c) => {
    let card_number = c.pathParam("card_number")
    let card_holder_name = c.pathParam("card_holder_name")
// $apis.requestInfo(c).authRecord.permissions.allowed_to_edit_rfid
    if (true) {
        const RFID_data = $os.exec("python3", "/home/austin/pb_hooks/add_rfid.py").output()
        console.log(RFID_data)
        if (RFID_data === "Failed - Took too long") {
            throw new ApiError(500, "Took too long", "RFID card to write to wasn't found in the time limit")
        } else if (RFID_data === "Failed - Something else") {
            throw new ApiError(500, "Something went wrong", ":/")
        } else {
            const record = new Record("rfid_cards", {
                "card_number": card_number,
                "card_holder_name": card_holder_name,
                "data": RFID_data
            })
            $app.dao().saveRecord(record)
        }
    } else {
        throw new ForbiddenError("Nice try, but only an account with RFID edit permissions can do this")
    }
})