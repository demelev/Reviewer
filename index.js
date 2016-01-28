require('coffee-script/register')

var express = require('express');
var app = express();
var http    = require('http').Server(app);
var path    = require('path');
var session = require('express-session');
var bparser = require('body-parser');

var loadData = require('./src/ReadData');
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

    loadData.load_data(req.body.url, function(data){
        var file = fs.createWriteStream(__dirname + '/public/data.csv');
        file.write(data);
        file.end();
        res.redirect("/members");
    });
});

app.get('/members', function(req, res) {
    res.sendFile(__dirname + '/members.html');
});

http.listen(8888, function(){
    console.log('Listening on *:8888');
});
