express = require('express')
app = express()
path = require('path')

#app.use(express.static(__dirname)); # Current directory is root
app.use(express.static(path.join(__dirname, 'static'))) #  "public" off of current is root

app.listen(8080);
console.log('Listening on port 8080');
