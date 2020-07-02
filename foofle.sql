-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 22, 2020 at 12:55 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foofle`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `changeinfo` (IN `newpass` VARCHAR(20), IN `newaccphon` VARCHAR(20), IN `newfname` VARCHAR(20), IN `newlname` VARCHAR(20), IN `newphone` VARCHAR(20), IN `newbdate` DATE, IN `newnick` VARCHAR(20), IN `newidnum` VARCHAR(20), IN `newadd` VARCHAR(500), IN `newacces` TINYINT(1))  begin
    declare tempid int;
    set @tempid = getcurruserid();
    if newpass like '______%'
    then
        update userslogininfo
        set accphonenumber=newaccphon,password=md5(newpass)
        where id=@tempid;
        update usersinfo
        set firstname=newfname,lastname=newlname,phonenumber=newphone,birthdate=newbdate,nickname=newnick,identifiernumber=newidnum,address=newadd,accessibility=newacces
        where id=@tempid;
    else
        begin
            select 'not enough pass length';
        end;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteemail` (IN `myemailid` INT)  begin
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select lower(username) into myusername from userslogininfo where id=@tempid;
    update deleterecstatus
    set status=1
    where lower(username)=myusername and emailid=myemailid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteme` ()  begin
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select lower(username) into myusername from userslogininfo where id=@tempid;
    delete from accessexceptions where userid=@tempid or ownerid=@tempid;
    delete from deleterecstatus where lower(username)=myusername;
    delete from deletesendstatus where lower(username)=myusername;
    delete from emails where lower(senderusername)=myusername;
    delete from logginlog where id=@tempid;
    delete from noaccesseceptions where userid=@tempid or ownerid=@tempid;
    delete from notifications where userid=@tempid;
    delete from readingstatus where lower(username)=myusername;
    delete from receivers where lower(username)=myusername;
    delete from receiverscc where lower(username)=myusername;
    delete from usersinfo where id=@tempid;
    delete from userslogininfo where id=@tempid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletesentemail` (IN `myemailid` INT)  begin
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select lower(username) into myusername from userslogininfo where id=@tempid;
    update deletesendstatus
    set status=1
    where lower(username)=myusername and emailid=myemailid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `denyaccessto` (IN `myusername` VARCHAR(20))  begin
    declare myuserid int;
    select id into myuserid from userslogininfo where lower(myusername)=lower(username);
    set @tempid=getcurruserid();
    if not exists(select id from userslogininfo where id=myuserid)
    then
    select 'there is not such a user';
    else
        insert into noaccesseceptions(ownerid, userid) VALUES (@tempid,myuserid);
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getinfocurruser` ()  begin
    declare tempid int;
    set @tempid=getcurruserid();
    select *
    from userslogininfo natural join usersinfo
    where usersinfo.id=@tempid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getmyemails` (IN `pagenumber` INT)  begin
    declare start int;
    declare end int;
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select lower(username) into myusername from userslogininfo where id=@tempid;
    set end=pagenumber*10;
    set start = ((pagenumber-1)*10);
    select * from emails e natural join readingstatus t where (e.emailid in (select emailid from receivers where lower(username)=myusername) or e.emailid in (select emailid from receiverscc where lower(username)=myusername)) and lower(t.username)=myusername and e.emailid not in(select emailid from deleterecstatus d where d.status=true and lower(d.username)=myusername) order by e.sendtime desc limit start,end;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getmysentemails` (IN `pagenumber` INT)  begin
    declare start int;
    declare end int;
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select lower(username) into myusername from userslogininfo where id=@tempid;
    set end=pagenumber*10;
    set start = ((pagenumber-1)*10);
    select * from emails e  where lower(e.senderusername)=myusername and e.emailid not in (select emailid from deletesendstatus where status=1 and lower(username)=myusername) order by e.sendtime desc limit start,end;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getnotifications` ()  begin
        declare tempid int;
        set @tempid=getcurruserid();
        select *
        from notifications
        where userid=@tempid
        order by mydatetime desc;
    end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getuserinfo` (IN `myusername` VARCHAR(20))  begin
    declare tempid int;
    declare supervisedid int;
    declare useraccesibility boolean;
    set @tempid=getcurruserid();
    select id into supervisedid from userslogininfo where lower(username)=lower(myusername);
    select accessibility into useraccesibility from usersinfo where id=supervisedid;
    if not exists(select id from userslogininfo where lower(username)=lower(myusername))
    then
        select 'there is not such a user';
    else
        begin
            if useraccesibility=1
            then
                begin
                    if not exists(select userid from noaccesseceptions where ownerid=supervisedid and userid=@tempid)
                    then
                        select * from usersinfo where id=supervisedid;
                        insert into notifications(mydatetime, content, userid) values (NOW(),concat('user with id:',@tempid,'tried to access info and  had access'),supervisedid);
                    else
                        begin
                            select 'u dont have access';
                            select * from usersinfo where firstname='*';
                            insert into notifications(mydatetime, content, userid) values (NOW(),concat('user with id:',@tempid,'tried to access info and didnt had access'),supervisedid);
                        end;
                    end if;
                end;
            else
                begin
                    if not exists(select userid from accessexceptions where ownerid=supervisedid and userid=@tempid)
                    then
                        select 'u dont have access';
                        select * from usersinfo where firstname='*';
                        insert into notifications(mydatetime, content, userid) values (NOW(),concat('user with id:',@tempid,'tried to access info and didnt had access'),supervisedid);
                    else
                        select * from usersinfo where id=supervisedid;
                        insert into notifications(mydatetime, content, userid) values (NOW(),concat('user with id:',@tempid,'tried to access info and had access'),supervisedid);
                    end if;
                end;
            end if;
        end;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `giveaccessto` (IN `myusername` VARCHAR(20))  begin
    declare myuserid int;
    select id into myuserid from userslogininfo where lower(username)=lower(myusername);
    set @tempid=getcurruserid();
    if not exists(select id from userslogininfo where id=myuserid)
    then
    select 'there is not such a user';
    else
        insert into accessexceptions(ownerid, userid) VALUES (@tempid,myuserid);
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `myusername` VARCHAR(20), IN `mypassword` VARCHAR(32))  begin
        if not exists(select username from userslogininfo where lower(username)=lower(myusername))
        then
            select 'there is not such a username';
        else 
            begin
                declare temp varchar(32);
                declare tempid int;
                select password into temp
                from userslogininfo
                where lower(username)=lower(myusername);
                if temp=md5(mypassword)
                then
                select 'success';
                select id into tempid from userslogininfo where lower(username)=lower(myusername);
                insert into logginlog(id, timelogged) values (tempid,now());
                else 
                select 'wrong pass';
                end if;
            end;
        end if;
    end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mysignup` (IN `myusername` VARCHAR(20), IN `mypassword` VARCHAR(20), IN `myaccphonenumber` VARCHAR(20), IN `myfirstname` VARCHAR(20), IN `mylastname` VARCHAR(20), IN `myphonenumber` VARCHAR(20), IN `mybirthdate` DATE, IN `mynickname` VARCHAR(20), IN `idnum` VARCHAR(20), IN `myaddress` VARCHAR(500), IN `myaccessibility` BOOLEAN)  begin
        if not exists(select username from userslogininfo where myusername=username)
        then
            begin
                if myusername LIKE '______%' and mypassword like '______%'
                then
                    begin
                        start transaction;
                        insert into userslogininfo(username, password, datecreated, accphonenumber)
                        values (myusername,md5(mypassword),NOW(),myaccphonenumber);
                        insert into usersinfo(firstname, lastname,phonenumber, birthdate, nickname,identifiernumber,address,accessibility)
                        values(myfirstname,mylastname,myphonenumber,mybirthdate,mynickname,idnum,myaddress,myaccessibility);
                        commit ;
                    end;
                    rollback;
                else 
                    select 'not enough length';
                end if;
            end;
        else 
            select 'there is one record with this username';
        end if;
    end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reademail` (IN `myemailid` INT)  begin
    declare myusername varchar(20);
    set @tempid=getcurruserid();
    select username into myusername from userslogininfo where id=@tempid;
    update readingstatus
    set status=1
    where username=myusername and emailid=myemailid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sendEmail` (IN `mysubject` VARCHAR(20), IN `mycontent` VARCHAR(500), IN `recusername1` VARCHAR(20), IN `recusername2` VARCHAR(20), IN `recusername3` VARCHAR(20), IN `recusername1cc` VARCHAR(20), IN `recusername2cc` VARCHAR(20), IN `recusername3cc` VARCHAR(20))  begin
    declare tempid int;
    declare myemailid int;
    declare sender varchar(20);
    declare rec1val boolean;
    declare rec1ccval boolean;
    declare rec2val boolean;
    declare rec2ccval boolean;
    declare rec3val boolean;
    declare rec3ccval boolean;
    set @tempid=getcurruserid();
    select lower(username) into sender from userslogininfo where id=@tempid;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername1))
    then
        select false into rec1val;
    else
        select true into rec1val;
    end if;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername1cc))
    then
        select false into rec1ccval;
    else
        select true into rec1ccval;
    end if;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername2))
    then
        select false into rec2val;
    else
        select true into rec2val;
    end if;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername2cc))
    then
        select false into rec2ccval;
    else
        select true into rec2ccval;
    end if;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername3))
    then
        select false into rec3val;
    else
        select true into rec3val;
    end if;
    if not exists(select * from userslogininfo where lower(username)=lower(recusername3cc))
    then
        select false into rec3ccval;
    else
        select true into rec3ccval;
    end if;

    if rec1val=false and rec1ccval=false and rec2val=false and rec2ccval=false and rec3val=false and rec3ccval=false
    then
        select 'there is no valid receiver';
    else
        begin
            
            insert into emails(senderusername, subject, sendtime, content) values (sender,mysubject,NOW(),mycontent);
            select emailid into myemailid from emails where emailid=last_insert_id();
            insert into deletesendstatus(emailid, username, status) values (myemailid,sender,0);
            if rec1val=true
            then
                begin
                insert into receivers(emailid, username) VALUES (myemailid,lower(recusername1));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername1),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername1),0);
                end;
            else
                select 'rec1 is not valid';
            end if;
            if rec1ccval=true
            then
                begin
                insert into receiverscc(emailid, username) VALUES (myemailid,lower(recusername1cc));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername1cc),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername1cc),0);
                end;
            else
                select 'rec1cc is not valid';
            end if;
            if rec2val=true
            then
                begin 
                insert into receivers(emailid, username) VALUES (myemailid,lower(recusername2));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername2),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername2),0);
                end;
            else
                select 'rec2 is not valid';
            end if;
            if rec2ccval=true
            then
                begin 
                insert into receiverscc(emailid, username) VALUES (myemailid,lower(recusername2cc));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername2cc),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername2cc),0);
                end;
            else
                select 'rec2cc is not valid';
            end if;
            if rec3val=true
            then
                begin 
                insert into receivers(emailid, username) VALUES (myemailid,lower(recusername3));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername3),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername3),0);
                end;
            else
                select 'rec3 is not valid';
            end if;
            if rec3ccval=true
            then
                begin
                insert into receiverscc(emailid, username) VALUES (myemailid,lower(recusername3cc));
                insert into readingstatus(username, emailid, status) VALUES (lower(recusername3cc),myemailid,0);
                insert into deleterecstatus(emailid, username, status) VALUES (myemailid,lower(recusername3cc),0);
                end;
            else
                select 'rec3cc is not valid';
            end if;
            select 'sucess';
        end;
    end if;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getcurruserid` () RETURNS INT(11) begin
        declare userid int;
        select id into userid from logginlog order by timelogged desc limit 1;
        return userid;
    end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `accessexceptions`
--

CREATE TABLE `accessexceptions` (
  `ownerid` int(11) NOT NULL,
  `userid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `deleterecstatus`
--

CREATE TABLE `deleterecstatus` (
  `emailid` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `deleterecstatus`
--
DELIMITER $$
CREATE TRIGGER `deletrecemailnotify` AFTER UPDATE ON `deleterecstatus` FOR EACH ROW begin
    declare tempid int;
    if (new.status=1 and old.status=0)
    then
        begin
        select id into tempid from userslogininfo where lower(userslogininfo.username)=lower(new.username);
        insert into notifications(mydatetime, content, userid) VALUES (now(),concat('You have deleted email with email id:',new.emailid),tempid);
        end;
    end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `deletesendstatus`
--

CREATE TABLE `deletesendstatus` (
  `emailid` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `deletesendstatus`
--
DELIMITER $$
CREATE TRIGGER `deletsendemailnotify` AFTER UPDATE ON `deletesendstatus` FOR EACH ROW begin
    declare tempid int;
    if (new.status=1 and old.status=0)
    then
        begin
        select id into tempid from userslogininfo where lower(userslogininfo.username)=lower(new.username);
        insert into notifications(mydatetime, content, userid) VALUES (now(),concat('You have deleted sent email with email id:',new.emailid),tempid);
        end;
    end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `emails`
--

CREATE TABLE `emails` (
  `emailid` int(11) NOT NULL,
  `senderusername` varchar(20) NOT NULL,
  `subject` varchar(20) NOT NULL,
  `sendtime` datetime NOT NULL,
  `content` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `logginlog`
--

CREATE TABLE `logginlog` (
  `id` int(11) NOT NULL,
  `timelogged` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `logginlog`
--

INSERT INTO `logginlog` (`id`, `timelogged`) VALUES
(25, '2020-06-21 15:46:31');

--
-- Triggers `logginlog`
--
DELIMITER $$
CREATE TRIGGER `loginnotification` AFTER INSERT ON `logginlog` FOR EACH ROW insert into notifications(mydatetime, content, userid) values (NOW(),'Welcome back,you have logged in succesfully',NEW.id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `noaccesseceptions`
--

CREATE TABLE `noaccesseceptions` (
  `ownerid` int(11) NOT NULL,
  `userid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `mydatetime` datetime DEFAULT NULL,
  `content` varchar(500) DEFAULT NULL,
  `userid` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`mydatetime`, `content`, `userid`) VALUES
('2020-06-21 15:46:07', 'You have signed up succesfully. welcome to the foofle', '25'),
('2020-06-21 15:46:31', 'Welcome back,you have logged in succesfully', '25');

-- --------------------------------------------------------

--
-- Table structure for table `readingstatus`
--

CREATE TABLE `readingstatus` (
  `username` varchar(20) NOT NULL,
  `emailid` int(11) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `receivers`
--

CREATE TABLE `receivers` (
  `emailid` int(11) NOT NULL,
  `username` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `receivers`
--
DELIMITER $$
CREATE TRIGGER `newemailnotifiy` AFTER INSERT ON `receivers` FOR EACH ROW begin
    declare tempid int;
    select id into tempid from userslogininfo where username=new.username;
    insert into notifications(mydatetime, content, userid) VALUES (NOW(),'you have newemail',tempid);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `receiverscc`
--

CREATE TABLE `receiverscc` (
  `emailid` int(11) NOT NULL,
  `username` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `receiverscc`
--
DELIMITER $$
CREATE TRIGGER `newemailccnotifiy` AFTER INSERT ON `receiverscc` FOR EACH ROW begin
    declare tempid int;
    select id into tempid from userslogininfo where username=new.username;
    insert into notifications(mydatetime, content, userid) VALUES (NOW(),'you have newemail',tempid);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `usersinfo`
--

CREATE TABLE `usersinfo` (
  `id` int(11) NOT NULL,
  `firstname` varchar(20) NOT NULL,
  `lastname` varchar(20) NOT NULL,
  `phonenumber` varchar(20) NOT NULL,
  `birthdate` date NOT NULL,
  `nickname` varchar(20) NOT NULL,
  `identifiernumber` varchar(20) NOT NULL,
  `address` varchar(500) NOT NULL,
  `accessibility` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `usersinfo`
--

INSERT INTO `usersinfo` (`id`, `firstname`, `lastname`, `phonenumber`, `birthdate`, `nickname`, `identifiernumber`, `address`, `accessibility`) VALUES
(0, '*', '*', '*', '2020-06-21', '*', '*', '*', 0),
(25, '123', '123', '123', '1998-12-03', '123', '123', '123', 1);

--
-- Triggers `usersinfo`
--
DELIMITER $$
CREATE TRIGGER `changeaccessnotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.accessibility!=OLD.accessibility
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your accesibility has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changeaddresnotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.address!=OLD.address
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your address has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changebdatenotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.birthdate!=OLD.birthdate
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your birth date has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changefnamenotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.firstname!=OLD.firstname
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your firstname has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changeidnumnotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.identifiernumber!=OLD.identifiernumber
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your idnumber has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changelnamenotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.lastname!=OLD.lastname
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your lastname has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changenicknotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.nickname!=OLD.nickname
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your nickname has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changephonenotification` AFTER UPDATE ON `usersinfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.phonenumber!=OLD.phonenumber
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your phonenumber has changed',@tempid);
    end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `userslogininfo`
--

CREATE TABLE `userslogininfo` (
  `id` int(11) NOT NULL,
  `username` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `password` varchar(32) NOT NULL,
  `datecreated` datetime NOT NULL,
  `accphonenumber` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `userslogininfo`
--

INSERT INTO `userslogininfo` (`id`, `username`, `password`, `datecreated`, `accphonenumber`) VALUES
(0, '*', '*', '2020-06-21 15:26:35', '*'),
(25, 'shayantest', 'a9bf3e57de8ddf9d165bf4bc29ae3496', '2020-06-21 15:46:07', '123');

--
-- Triggers `userslogininfo`
--
DELIMITER $$
CREATE TRIGGER `changeaccphonenotification` AFTER UPDATE ON `userslogininfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.accphonenumber!=OLD.accphonenumber
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your accphonenumber has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changepassnotification` AFTER UPDATE ON `userslogininfo` FOR EACH ROW begin
    declare tempid int;
    set @tempid=getcurruserid();
    if new.password!=OLD.password
    then
        insert into notifications(mydatetime, content, userid) VALUES (NOW(),'Your password has changed',@tempid);
    end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `signupnotification` AFTER INSERT ON `userslogininfo` FOR EACH ROW insert into notifications(mydatetime, content, userid) values (NOW(),'You have signed up succesfully. welcome to the foofle',NEW.id)
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `emails`
--
ALTER TABLE `emails`
  ADD PRIMARY KEY (`emailid`);

--
-- Indexes for table `usersinfo`
--
ALTER TABLE `usersinfo`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `userslogininfo`
--
ALTER TABLE `userslogininfo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `id_2` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `emails`
--
ALTER TABLE `emails`
  MODIFY `emailid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `usersinfo`
--
ALTER TABLE `usersinfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `userslogininfo`
--
ALTER TABLE `userslogininfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
