require('coffee-script/register')

var express = require('express');
var app = express();
var http    = require('http').Server(app);
var path    = require('path');
var session = require('express-session');
var bparser = require('body-parser');

var loadData = require('./src/ReadData');
var review_parser = require('./src/review_parser');

var fs = require('fs')

// Configure app
app.use(express.static(path.join(__dirname, 'public')));
app.use(bparser.urlencoded({ extended: false }))
app.use(bparser.json());
//app.use(cparser());
app.use(session({secret:'dwsecretbackend'}));

app.get('/', function(req, res) {
    res.sendFile(__dirname + '/index.html');
});

app.post('/load_from', function(req, res) {

    // load members list
/*
 *    loaddata.load_data(req.body.members_list_url, function(data) {
 *        console.log("Names: " + data);
 *
 *        var file = fs.createWriteStream(__dirname + '/public/members.csv');
 *        file.write(data);
 *        file.end();
 *    });
 */

    var members_data = fs.readFileSync(__dirname + '/public/members.csv');

    // load cvs file from google sheets.
    loadData.load_data(req.body.url, function(data) {
        var file = fs.createWriteStream(__dirname + '/public/data.csv');
        file.write(data);
        file.end();

        var review_result = review_parser.parse(members_data, data);
        console.log(review_result);
        res.redirect("/members");
    });
});

app.get('/members', function(req, res) {
    res.sendFile(__dirname + '/members.html');
});

http.listen(8888, function(){
    console.log('Listening on *:8888');
});
