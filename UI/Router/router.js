const express = require('express');
const router = express.Router();
const mariadb=require('mariadb');
const url = require('url');


router.get('/',function(req,res){
    res.render('welcome.ejs');
    res.end();
})

router.get('/signup',function(req,res){
    res.render('signup.ejs');
    res.end();
})
router.post('/signup',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL mysignup("+"\'"+req.body.username+"\',"+"\'"+req.body.password+"\',"+"\'"+req.body.accphonenumber+"\',"+"\'"+req.body.firstname+"\',"+"\'"+req.body.lastname+"\',"+"\'"+req.body.phonenumber+"\',"+"\'"+req.body.birthdate+"\',"+"\'"+req.body.nickname+"\',"+"\'"+req.body.idnum+"\',"+"\'"+req.body.address+"\',"+req.body.accessibility+")";
        db.query(query).then(result=>{
            if(result[0]==undefined){
                res.render('result.ejs',{data:'success'});
                res.end();
            }
            else{
                res.render('result.ejs',{data:Object.keys(result[0][0])[0]});
                res.end();  
            }
        }).catch(err=>{
            res.render('result.ejs',{data:'invalid input'});
                res.end();
        })
    })
})

router.get('/login',function(req,res){
    res.render('login.ejs');
    res.end();
})
router.post('/login',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL login("+"\'"+req.body.username+"\',\'"+req.body.pass+"\')";
        db.query(query).then(result=>{
            if(Object.keys(result[0][0])[0]=="success"){
                res.redirect('/dashboard');
            }
            else{
                res.render('result.ejs',{data:Object.keys(result[0][0])[0]});
                res.end();
            }
        })
    })
})

router.get("/dashboard",function(req,res){
    res.render('index.ejs');
    res.end();
})

router.get('/getnotifications',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL getnotifications()"
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result[0].length;i++){
                values.push(Object.values(result[0][i]));
            }
            res.render('table.ejs',{headers:Object.keys(result[0][0]),values:values});
            res.end();
        }).catch(err=>{
            res.render('result.ejs',{data:'execption occured'});
            res.end();
        })
    })
})

router.get('/getmyinfo',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL getinfocurruser()"
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result[0].length;i++){
                values.push(Object.values(result[0][i]));
            }
            res.render('table.ejs',{headers:Object.keys(result[0][0]),values:values});
            res.end();
        }).catch(err=>{
            res.render('result.ejs',{data:'execption occured'});
            res.end();
        })
    })
})

router.get('/getothersinfo',function(req,res){
    res.render('getuserinfo.ejs');
    res.end();
})

router.post('/getothersinfo',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL getuserinfo("+"\'"+req.body.username+"\')";
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result[0].length;i++){
                values.push(Object.values(result[0][i]));
            }
            if(values[0][0]=="u dont have access"){
                var values2=[];
                for(let i=0;i<result[1].length;i++){
                    values2.push(Object.values(result[1][i]));
                }
                res.render('table.ejs',{headers:Object.keys(result[1][0]),values:values2});
                res.end();
            }
            else{
                res.render('table.ejs',{headers:Object.keys(result[0][0]),values:values});
                res.end();
            }
        }).catch(err=>{
            res.render('result.ejs',{data:'execption occured'});
            res.end();
        })
    })
})

router.get('/changeinfo',function(req,res){
    res.render("changeinfo.ejs");
    res.end();
})

router.post('/changeinfo',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL changeinfo("+"\'"+req.body.password+"\',"+"\'"+req.body.accphonenumber+"\',"+"\'"+req.body.firstname+"\',"+"\'"+req.body.lastname+"\',"+"\'"+req.body.phonenumber+"\',"+"\'"+req.body.birthdate+"\',"+"\'"+req.body.nickname+"\',"+"\'"+req.body.idnum+"\',"+"\'"+req.body.address+"\',"+req.body.accessibility+")";
        console.log(query)
        db.query(query).then(result=>{
            if(result[0]==undefined){
                res.render('result.ejs',{data:'success'});
                res.end();
            }
            else{
                res.render('result.ejs',{data:Object.keys(result[0][0])[0]});
                res.end();  
            }
        }).catch(err=>{
            res.render('result.ejs',{data:'invalid input'});
            res.end();
        })
    })
})

router.get('/deleteaccount',function(req,res){

})

router.get('/sendemail',function(req,res){
    res.render('sendemail.ejs');
    res.end();
})

router.post('/sendemail',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL sendEmail("+"\'"+req.body.subject+"\',"+"\'"+req.body.content+"\',"+"\'"+req.body.rec1.split("@")[0]+"\',"+"\'"+req.body.rec2.split("@")[0]+"\',"+"\'"+req.body.rec3.split("@")[0]+"\',"+"\'"+req.body.rec1cc.split("@")[0]+"\',"+"\'"+req.body.rec2cc.split("@")[0]+"\',"+"\'"+req.body.rec3cc.split("@")[0]+"\')";
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result.length-1;i++){
                values.push(Object.keys(result[i][0]));
            }
            console.log(values);
            res.render('table.ejs',{headers:["results:"],values:values});
            res.end();
        }).catch(err=>{
            res.render('result.ejs',{data:'execption occured'});
            res.end();
        })
    })
})

router.get('/inbox',function(req,res){
    var sitequery = url.parse(req.url,true).query;
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL getmyemails("+sitequery.page+")";
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result[0].length;i++){
                values.push(Object.values(result[0][i]));
            }
            res.render('tablewithpage.ejs',{headers:Object.keys(result[0][0]),values:values});
            res.end();
        }).catch(err=>{
            res.render('result.ejs',{data:'no more email'});
            res.end();
        })
    })
})

router.get('/read',function(req,res){
    var sitequery = url.parse(req.url,true).query;
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL reademail("+sitequery.emailid+")";
        db.query(query).then(result=>{
            res.redirect('/inbox?page=1');
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.get('/delete',function(req,res){
    var sitequery = url.parse(req.url,true).query;
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL deleteemail("+sitequery.emailid+")";
        db.query(query).then(result=>{
            res.redirect('/inbox?page=1');
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.get('/sentinbox',function(req,res){
    var sitequery = url.parse(req.url,true).query;
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL getmysentemails("+sitequery.page+")";
        db.query(query).then(result=>{
            var values=[];
            for(let i=0;i<result[0].length;i++){
                values.push(Object.values(result[0][i]));
            }
            res.render('tablewithpage2.ejs',{headers:Object.keys(result[0][0]),values:values});
            res.end();
        }).catch(err=>{
            res.render('result.ejs',{data:'no more email'});
            res.end();
        })
    })
})

router.get('/deleteaccount1',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL deleteme()"
        db.query(query).then(result=>{
            console.log(result);
            res.redirect('/');
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.get('/deletesent',function(req,res){
    var sitequery = url.parse(req.url,true).query;
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL deletesentemail("+sitequery.emailid+")";
        db.query(query).then(result=>{
            res.redirect('/sentinbox?page=1');
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.post('/giveaccessto',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL giveaccessto(\'"+req.body.username+"\')";
        db.query(query).then(result=>{
            if(result[0]==undefined){
                res.redirect('/dashboard');
            }
            else{
            res.render('result.ejs',{data:Object.keys(result[0][0])[0]})
            }
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.post('/denyaccessto',function(req,res){
    const pool = mariadb.createPool({
        host: 'localhost', 
        user:'root', 
        password: '',
        database:'foofle',
        connectionLimit: 5
    });
    pool.getConnection().then(db=>{
        var query="CALL denyaccessto(\'"+req.body.username+"\')";
        db.query(query).then(result=>{
            if(result[0]==undefined){
                res.redirect('/dashboard');
            }
            else{
            res.render('result.ejs',{data:Object.keys(result[0][0])[0]})
            }
        }).catch(err=>{
            res.render('result.ejs',{data:'exception'});
            res.end();
        })
    })
})

router.get('*',function(req,res){
    res.render('404.ejs');
    res.end();
})



module.exports = router;