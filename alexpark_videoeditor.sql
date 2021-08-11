-- phpMyAdmin SQL Dump
-- version 4.9.5deb2
-- https://www.phpmyadmin.net/
--
-- 主机： localhost:3306
-- 生成日期： 2021-07-27 12:01:18
-- 服务器版本： 10.3.29-MariaDB-0ubuntu0.20.04.1
-- PHP 版本： 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `alexpark_videoeditor`
--
CREATE DATABASE IF NOT EXISTS `alexpark_videoeditor` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `alexpark_videoeditor`;

-- --------------------------------------------------------

--
-- 表的结构 `apikey`
--

CREATE TABLE `apikey` (
  `keyid` bigint(20) NOT NULL,
  `apikey` varchar(255) NOT NULL,
  `groupid` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `apikey`
--

INSERT INTO `apikey` (`keyid`, `apikey`, `groupid`) VALUES
(1, '3mn.net-123456789987654321', 1),
(2, '3mn.net-public-common', 1);

-- --------------------------------------------------------

--
-- 表的结构 `consolelog`
--

CREATE TABLE `consolelog` (
  `cid` bigint(20) NOT NULL,
  `logstamp` datetime NOT NULL DEFAULT current_timestamp(),
  `log` varchar(4096) NOT NULL,
  `readover` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- 表的结构 `globalcache`
--

CREATE TABLE `globalcache` (
  `gid` bigint(20) NOT NULL,
  `keystr` varchar(32) NOT NULL,
  `valuestr` varchar(8192) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转存表中的数据 `globalcache`
--

INSERT INTO `globalcache` (`gid`, `keystr`, `valuestr`) VALUES
(1, 'tasklooptotal', '163726'),
(2, 'currenttaskid', '0'),
(3, 'echostring', ''),
(4, 'enablelog', 'true');

-- --------------------------------------------------------

--
-- 表的结构 `privatelib`
--

CREATE TABLE `privatelib` (
  `itemid` bigint(20) NOT NULL,
  `resfilename` varchar(255) NOT NULL,
  `apikey` varchar(255) NOT NULL,
  `titlepic` varchar(255) NOT NULL DEFAULT 'temp.jpg',
  `resfileclass` varchar(31) NOT NULL DEFAULT 'mp4',
  `createstamp` datetime NOT NULL DEFAULT current_timestamp(),
  `resfiledesc` varchar(255) NOT NULL DEFAULT '-',
  `restimelength` varchar(16) NOT NULL DEFAULT '00:00:00.000',
  `resfps` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- 表的结构 `publiclib`
--

CREATE TABLE `publiclib` (
  `itemid` bigint(20) NOT NULL,
  `resfilename` varchar(255) NOT NULL,
  `apikey` varchar(255) NOT NULL,
  `titlepic` varchar(255) NOT NULL DEFAULT 'temp.jpg',
  `resfileclass` varchar(31) NOT NULL DEFAULT 'mp4',
  `createstamp` datetime NOT NULL DEFAULT current_timestamp(),
  `resfiledesc` varchar(255) NOT NULL DEFAULT '-',
  `restimelength` varchar(16) NOT NULL DEFAULT '00:00:00.000',
  `resfps` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- 表的结构 `task`
--

CREATE TABLE `task` (
  `tid` bigint(20) NOT NULL,
  `taskid` varchar(32) NOT NULL,
  `taskclass` varchar(64) NOT NULL DEFAULT 'regular',
  `taskdesc` varchar(255) NOT NULL DEFAULT '-',
  `taskstatus` varchar(255) NOT NULL DEFAULT 'processing',
  `resultfile` varchar(255) NOT NULL,
  `finalwidth` int(11) NOT NULL,
  `finalheight` int(11) NOT NULL,
  `taskargs` varchar(1024) NOT NULL,
  `finallength` int(11) NOT NULL,
  `apikey` varchar(255) NOT NULL,
  `createstamp` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- 表的结构 `videolayerstruct`
--

CREATE TABLE `videolayerstruct` (
  `slbid` bigint(20) NOT NULL,
  `blockidx` int(11) NOT NULL,
  `blockid` int(11) NOT NULL,
  `resfilename` varchar(255) NOT NULL,
  `createstamp` datetime NOT NULL,
  `fromstamp` int(11) NOT NULL,
  `tostamp` int(11) NOT NULL,
  `blocklength` int(11) NOT NULL,
  `fileclass` varchar(16) NOT NULL,
  `blockcolor` bigint(20) NOT NULL,
  `ispubliclib` tinyint(1) NOT NULL,
  `simularity` double NOT NULL,
  `blend` double NOT NULL,
  `filestartpos` int(11) NOT NULL,
  `resizeleft` int(11) NOT NULL,
  `resizetop` int(11) NOT NULL,
  `resizewidth` int(11) NOT NULL,
  `resizeheight` int(11) NOT NULL,
  `resizeenable` tinyint(1) NOT NULL,
  `respeed` double NOT NULL,
  `respeedenable` tinyint(1) NOT NULL,
  `revolume` double NOT NULL,
  `revolumeenable` tinyint(1) NOT NULL,
  `layercreatestamp` datetime NOT NULL,
  `zindex` int(11) NOT NULL,
  `layerlength` int(11) NOT NULL,
  `layeridx` int(11) NOT NULL,
  `layerid` int(11) NOT NULL,
  `structcreatestamp` datetime NOT NULL,
  `scalefactor` double NOT NULL,
  `taskid` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 转储表的索引
--

--
-- 表的索引 `apikey`
--
ALTER TABLE `apikey`
  ADD PRIMARY KEY (`keyid`);

--
-- 表的索引 `consolelog`
--
ALTER TABLE `consolelog`
  ADD PRIMARY KEY (`cid`);

--
-- 表的索引 `globalcache`
--
ALTER TABLE `globalcache`
  ADD PRIMARY KEY (`gid`);

--
-- 表的索引 `privatelib`
--
ALTER TABLE `privatelib`
  ADD PRIMARY KEY (`itemid`),
  ADD KEY `fdidx` (`resfiledesc`);

--
-- 表的索引 `publiclib`
--
ALTER TABLE `publiclib`
  ADD PRIMARY KEY (`itemid`);

--
-- 表的索引 `task`
--
ALTER TABLE `task`
  ADD PRIMARY KEY (`tid`);

--
-- 表的索引 `videolayerstruct`
--
ALTER TABLE `videolayerstruct`
  ADD PRIMARY KEY (`slbid`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `apikey`
--
ALTER TABLE `apikey`
  MODIFY `keyid` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `consolelog`
--
ALTER TABLE `consolelog`
  MODIFY `cid` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `globalcache`
--
ALTER TABLE `globalcache`
  MODIFY `gid` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `privatelib`
--
ALTER TABLE `privatelib`
  MODIFY `itemid` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `publiclib`
--
ALTER TABLE `publiclib`
  MODIFY `itemid` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `task`
--
ALTER TABLE `task`
  MODIFY `tid` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `videolayerstruct`
--
ALTER TABLE `videolayerstruct`
  MODIFY `slbid` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
