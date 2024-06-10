onModelAfterCreate((e) => {
    const record = $app.dao().findRecordById("users", e.model.id)
    const username = record.username()
    console.log(username)
    console.log(record)
    if (username.includes("__noPasskey")) {
    console.log("returning - account wasn't made with passkey")
        return
    }
    const email = username.replace("__at__", "@")
    console.log(email)
    record.set("email", email)
    record.set("emailVisibility", true)
    $app.dao().saveRecord(record)

}, "users")
