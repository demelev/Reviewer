https = require 'https'

class DataReader
    read_data_from: (url, callback) ->
        console.log "Load data from #{url}"

        https.get url, (res) ->
            data = ""
            console.log "Got response #{res.statusCode}"

            res.on "data", (chunk) ->
                data += chunk

            res.on "end", () ->
                callback(data)


    load_from_url: (url, callback) ->
        this.read_data_from(url, (data) ->
            callback? data
        )


class Response
    constructor: (@name, data) ->


module.exports =
    load_data : (url, callback) ->
       reader = new DataReader()
       reader.load_from_url(url, callback)

