onMailerBeforeRecordVerificationSend((e) => {
    const recieverEmail = e.message['to'][0]['address'].toLowerCase();
    console.log(JSON.stringify(e.message['to']))

    if (recieverEmail.endsWith("sacredheart.school.nz")) {
        console.log("SHC Email Detected");

        e.message.subject = "Verify your SHC email"
    }
},)


onRecordAfterConfirmVerificationRequest((e) => {
    console.log("On record after confirm verification request")
    console.log(JSON.stringify(e))
    const e_record = JSON.parse(JSON.stringify(e.record))
    const email = e_record.email

    if (email.endsWith("@sacredheart.school.nz")) {
        console.log('ends with sacredheart.school.nz')
        const record = $app.dao().findRecordById('users', e_record.id)
        record.set("permissions", "0mf1jywqfhzsukh")
        record.set("signup_finished", true)
        record.set("balance", 0)
        record.set("pfp", `https://api.dicebear.com/8.x/shapes/svg?seed=${$security.pseudorandomString(10)}`)

        $app.dao().saveRecord(record)

    }
    if (email.endsWith("@students.sacredheart.school.nz")) {
        console.log("student email")
        const record = $app.dao().findRecordById("users", e_record.id)
        record.set("permissions", "498dm3tt0vuvgiw")
        record.set("signup_finished", true)
        record.set("balance", 0)
        record.set("pfp", `https://api.dicebear.com/8.x/shapes/svg?seed=${$security.pseudorandomString(10)}`)
        $app.dao().saveRecord(record)
    }
    if (!email.endsWith("sacredheart.school.nz")) {
        const record = $app.dao().findRecordById("users", e_record.id)
        record.set("permissions", "gkr18gwzscrz2j0")
        record.set("signup_finished", true)
        record.set("balance", 0)
        record.set("pfp", `https://api.dicebear.com/8.x/shapes/svg?seed=${$security.pseudorandomString(10)}`)
        $app.dao().saveRecord(record)
    }






},)


routerAdd("GET", "/api/shc/delete_account_after_passkey_failed/:email", (c) => {
    let username = c.pathParam("email")
    const record = $app.dao().findFirstRecordByData("users", "username", username)
    if (record.getBool("signup_finished") === true) {
        return c.json(403, { "message": "That account has finished signup" })
    } else {
        $app.dao().deleteRecord(record)
        return c.json(200, { "message": "Delted the old record!" })
    }
},)
