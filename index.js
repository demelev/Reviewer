require('coffee-script/register')

var express = require('express');
var app = express();
var http    = require('http').Server(app);
var path    = require('path');
var session = require('express-session');
var loadData = require('./src/ReadData');

// Configure app
app.use(express.static(path.join(__dirname, 'public')));
/*
 *app.use(bparser.urlencoded({ extended: false }))
 *app.use(bparser.json());
 *app.use(cparser());
 */
app.use(session({secret:'dwsecretbackend'}));

app.get('/', function(req, res) {
    res.sendFile(__dirname + '/index.html');
});

app.get('/members', function(req, res) {
    res.sendFile(__dirname + '/members.html');
});

loadData.read_data("http://google.com")

http.listen(8888, function(){
    console.log('Listening on *:8888');
});
