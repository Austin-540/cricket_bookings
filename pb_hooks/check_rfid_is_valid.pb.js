routerAdd("GET", "/api/shc/check_rfid_card_is_valid/", (c) => {
    const requesterInfo = $apis.requestInfo(c)
    const requesterPermissionsRel = requesterInfo.authRecord.get("permissions")
    const requesterPermissions = $app.dao().findRecordById("permissions", requesterPermissionsRel)

    if (!requesterPermissions.getBool("allowed_to_read_rfid")) {
        throw new UnauthorizedError("You are not allowed to check if cards are valid")
    }

    const reqData = $apis.requestInfo(c).data

    const cardString = reqData.card_data


    try{
        const cardRecord = $app.dao().findFirstRecordByFilter(
            "rfid_cards",
            `card_data = '${cardString}'`,
        )
        return c.json(200, { "valid": true })
    
    } catch (e) {
        throw new BadRequestError("Card not found")
    }
    


    
}, /* optional middlewares */)