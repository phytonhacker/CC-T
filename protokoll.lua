MSG = {
    PING      = "ping",
    PONG      = "pong",
    CMD       = "cmd",
    RESULT    = "result",
    LOG       = "log",
    REGISTER  = "register",
    FILE_SEND = "file_send",
    FILE_ACK  = "file_ack",
    FILE_ERR  = "file_err",
}

function csomagol(tipus, adat)
    return {
        tipus = tipus,
        adat  = adat,
        ido   = os.time(),
        kuldo = os.getComputerID()
    }
end