-- MySQL dump 10.13  Distrib 5.5.14, for Win32 (x86)
--
-- Host: localhost    Database: compendium
-- ------------------------------------------------------
-- Server version	5.5.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `compendium`
--

--
-- Table structure for table `annotationtype`
--

DROP TABLE IF EXISTS `annotationtype`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `annotationtype` (
  `idannotationtype` bigint(20) NOT NULL AUTO_INCREMENT,
  `annotationdescribes` text,
  `description` text,
  PRIMARY KEY (`idannotationtype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `annotationtype`
--

LOCK TABLES `annotationtype` WRITE;
/*!40000 ALTER TABLE `annotationtype` DISABLE KEYS */;
/*!40000 ALTER TABLE `annotationtype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chip`
--

DROP TABLE IF EXISTS `chip`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `chip` (
  `idchip` bigint(20) NOT NULL AUTO_INCREMENT,
  `idorganism` int(10) unsigned NOT NULL,
  `provider` text DEFAULT NULL,
  `description` text,
  `title` text,
  `distribution` text,
  `technology` text,
  `db_platform_id` text,
  `date_loaded` datetime DEFAULT NULL,
  PRIMARY KEY (`idchip`,`idorganism`),
  KEY `idorganism` (`idorganism`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chip`
--

LOCK TABLES `chip` WRITE;
/*!40000 ALTER TABLE `chip` DISABLE KEYS */;
/*!40000 ALTER TABLE `chip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chip_has_reporter`
--

DROP TABLE IF EXISTS `chip_has_reporter`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `chip_has_reporter` (
  `idchip` bigint(20) NOT NULL,
  `idspot` bigint(20) NOT NULL,
  PRIMARY KEY (`idchip`,`idspot`),
  KEY `fk_chip_has_reporter_chip` (`idchip`),
  KEY `fk_chip_has_reporter_reporter1` (`idspot`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chip_has_reporter`
--

LOCK TABLES `chip_has_reporter` WRITE;
/*!40000 ALTER TABLE `chip_has_reporter` DISABLE KEYS */;
/*!40000 ALTER TABLE `chip_has_reporter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment`
--

DROP TABLE IF EXISTS `experiment`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `experiment` (
  `idExperiment` bigint(20) NOT NULL AUTO_INCREMENT,
  `expname` text,
  `expdescr` text,
  `addeddate` datetime DEFAULT NULL,
  `tag` text DEFAULT NULL,
  `esetFileSize` bigint(20) DEFAULT NULL,
  `date_loaded` DATETIME NULL,
  PRIMARY KEY (`idExperiment`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment`
--

LOCK TABLES `experiment` WRITE;
/*!40000 ALTER TABLE `experiment` DISABLE KEYS */;
/*!40000 ALTER TABLE `experiment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_has_hyb`
--

DROP TABLE IF EXISTS `experiment_has_hyb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiment_has_hyb` (
  `idExperiment` bigint(20) NOT NULL,
  `hybid` bigint(20) NOT NULL,
  PRIMARY KEY (`idExperiment`,`hybid`),
  KEY `fk_experiment_has_hyb_experiment1` (`idExperiment`),
  KEY `fk_experiment_has_hyb_hyb1` (`hybid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_has_hyb`
--

LOCK TABLES `experiment_has_hyb` WRITE;
/*!40000 ALTER TABLE `experiment_has_hyb` DISABLE KEYS */;
/*!40000 ALTER TABLE `experiment_has_hyb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expressionset`
--

DROP TABLE IF EXISTS `expressionset`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `expressionset` (
  `idexpressionSet` int(11) NOT NULL AUTO_INCREMENT,
  `idExperiment` bigint(20) DEFAULT NULL,
  `idchip` bigint(20) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `filetype` varchar(100) DEFAULT NULL,
  `filesize` bigint(20) DEFAULT NULL,
  `filecontent` blob,
  PRIMARY KEY (`idexpressionSet`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expressionset`
--

LOCK TABLES `expressionset` WRITE;
/*!40000 ALTER TABLE `expressionset` DISABLE KEYS */;
/*!40000 ALTER TABLE `expressionset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gds`
--

DROP TABLE IF EXISTS `gds`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `gds` (
  `idGDS` int(20) NOT NULL AUTO_INCREMENT,
  `idchip` bigint(20) DEFAULT NULL, 
  `GDS` varchar(45) DEFAULT NULL,
  `datasetTitle` longtext,
  `datasetDescription` longtext,
  `datasetPUBMEDid` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`idGDS`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gds`
--

LOCK TABLES `gds` WRITE;
/*!40000 ALTER TABLE `gds` DISABLE KEYS */;
/*!40000 ALTER TABLE `gds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GPLannotation`
--

DROP TABLE IF EXISTS `GPLannotation`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `GPLannotation` (
  `idannotation` int(20) NOT NULL AUTO_INCREMENT,
  `supplierspotid` bigint(20) NOT NULL,
  `GeneTitle` longtext,
  `GeneSymbol` varchar(20) DEFAULT NULL,
  `GeneID` varchar(20) DEFAULT NULL,
  `UniGeneTitle` longtext,
  `UniGeneSymbol` varchar(20) DEFAULT NULL,
  `UniGeneID` varchar(10) DEFAULT NULL,
  `NucleotideTitle` longtext,
  `GI` int(20) DEFAULT NULL,
  `GBaccession` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idannotation`),
  KEY `supplierspotid` (`supplierspotid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GPLannotation`
--

LOCK TABLES `GPLannotation` WRITE;
/*!40000 ALTER TABLE `GPLannotation` DISABLE KEYS */;
/*!40000 ALTER TABLE `GPLannotation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hyb`
--

DROP TABLE IF EXISTS `hyb`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `hyb` (
  `hybid` bigint(20) NOT NULL AUTO_INCREMENT,
  `idchip` bigint(20) NOT NULL,
  `idGDS` int(20) DEFAULT NULL,
  `barcode` varchar(20) DEFAULT NULL,
  `hybdesign` text,
  `Sample_data_row_count` int(10) DEFAULT NULL,
  `load_data_count` int(10) DEFAULT NULL,
  `expdesign` TEXT NULL,
  PRIMARY KEY (`hybid`),
  KEY `idchip` (`idchip`),
  KEY `idGDS` (`idGDS`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hyb`
--

LOCK TABLES `hyb` WRITE;
/*!40000 ALTER TABLE `hyb` DISABLE KEYS */;
/*!40000 ALTER TABLE `hyb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hyb_has_description`
--

DROP TABLE IF EXISTS `hyb_has_description`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `hyb_has_description` (
  `descriptionid` bigint(20) NOT NULL AUTO_INCREMENT,
  `hybid` bigint(20) NOT NULL,
  `hyb_type` text,
  `hyb_description` text,
  PRIMARY KEY (`descriptionid`,`hybid`),
  KEY `hybid` (`hybid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hyb_has_description`
--

LOCK TABLES `hyb_has_description` WRITE;
/*!40000 ALTER TABLE `hyb_has_description` DISABLE KEYS */;
/*!40000 ALTER TABLE `hyb_has_description` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hyb_has_sample`
--

DROP TABLE IF EXISTS `hyb_has_sample`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `hyb_has_sample` (
  `hybid` bigint(20) NOT NULL,
  `idsample` bigint(20) NOT NULL,
  PRIMARY KEY (`hybid`,`idsample`),
  KEY `fk_hyb_has_sample_hyb1` (`hybid`),
  KEY `fk_hyb_has_sample_sample1` (`idsample`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hyb_has_sample`
--

LOCK TABLES `hyb_has_sample` WRITE;
/*!40000 ALTER TABLE `hyb_has_sample` DISABLE KEYS */;
/*!40000 ALTER TABLE `hyb_has_sample` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hybresult`
--

DROP TABLE IF EXISTS `hybresult`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `hybresult` (
  `idhybresult` bigint(20) NOT NULL AUTO_INCREMENT,
  `hybid` bigint(20) NOT NULL,
  `loaddate` date DEFAULT NULL,
  `submissiondate` date DEFAULT NULL,
  `description` text,
  `normalizedcolumn` int(10) unsigned DEFAULT NULL,
  `rawcolumn` int(10) unsigned DEFAULT NULL,
  `normalization` text,
  PRIMARY KEY (`idhybresult`),
  KEY `hybid` (`hybid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hybresult`
--

LOCK TABLES `hybresult` WRITE;
/*!40000 ALTER TABLE `hybresult` DISABLE KEYS */;
/*!40000 ALTER TABLE `hybresult` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organism`
--

DROP TABLE IF EXISTS `organism`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `organism` (
  `idorganism` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ncbiorgid` int(10) DEFAULT NULL,
  `officialname` text DEFAULT NULL,
  `shortname` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idorganism`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organism`
--

LOCK TABLES `organism` WRITE;
/*!40000 ALTER TABLE `organism` DISABLE KEYS */;
--INSERT INTO `organism` VALUES (1,9606,'Homo sapiens','human'),(2,10090,'Mus musculus','house mouse'),(3,10116,'Rattus norvegicus','Norway rat'),(4,9913,'Bos taurus','cow'),(5,4932,'Saccharomyces cerevisiae','baker\'s yeast');
/*!40000 ALTER TABLE `organism` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reference`
--

DROP TABLE IF EXISTS `reference`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `reference` (
  `idreference` bigint(20) NOT NULL AUTO_INCREMENT,
  `referencetype` text,
  `referencelink` text,
  `referencedesc` text,
  PRIMARY KEY (`idreference`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reference`
--

LOCK TABLES `reference` WRITE;
/*!40000 ALTER TABLE `reference` DISABLE KEYS */;
/*!40000 ALTER TABLE `reference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reporter`
--

DROP TABLE IF EXISTS `reporter`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `reporter` (
  `idspot` bigint(20) NOT NULL AUTO_INCREMENT,
  `idannotation` int(10),
  `featurenum` int(10) unsigned DEFAULT NULL,
  `description` text,
  `sequence` text,
  `gbaccession` text,
  `chromosome` text,
  `chrstart` int(10) unsigned DEFAULT NULL,
  `chrstop` int(10) unsigned DEFAULT NULL,
  `suppliername` text,
  `supplierspotid` text,
  `colnr` int(10) unsigned DEFAULT NULL,
  `rownr` int(10) unsigned DEFAULT NULL,
  `control_type` text,
  `annotationdate` datetime DEFAULT NULL,
  PRIMARY KEY (`idspot`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reporter`
--

LOCK TABLES `reporter` WRITE;
/*!40000 ALTER TABLE `reporter` DISABLE KEYS */;
/*!40000 ALTER TABLE `reporter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample`
--

DROP TABLE IF EXISTS `sample`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `sample` (
  `idsample` bigint(20) NOT NULL AUTO_INCREMENT,
  `sampletitle` text,
  `sampledesc` text,
  `sampleorg` text,
  `samplesource` text,
  `samplelabel` text,
  `samplemolecule` text,
  `sampleprovider` text,
  `sampletreatment` text,
  `samplecharacteristics` text,
  `samplegrowth` text,
  `sampledataprocessing` text,
  `providerid` text,
  `samplenumber` smallint(5) DEFAULT NULL,
  PRIMARY KEY (`idsample`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample`
--

LOCK TABLES `sample` WRITE;
/*!40000 ALTER TABLE `sample` DISABLE KEYS */;
/*!40000 ALTER TABLE `sample` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_has_sampleannotation`
--

DROP TABLE IF EXISTS `sample_has_sampleannotation`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `sample_has_sampleannotation` (
  `idsample` bigint(20) NOT NULL,
  `sampleannotation` bigint(20) NOT NULL,
  PRIMARY KEY (`idsample`,`sampleannotation`),
  KEY `fk_sample_has_sampleannotation_sample1` (`idsample`),
  KEY `fk_sample_has_sampleannotation_sampleannotation1` (`sampleannotation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_has_sampleannotation`
--

LOCK TABLES `sample_has_sampleannotation` WRITE;
/*!40000 ALTER TABLE `sample_has_sampleannotation` DISABLE KEYS */;
/*!40000 ALTER TABLE `sample_has_sampleannotation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sampleannotation`
--

DROP TABLE IF EXISTS `sampleannotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sampleannotation` (
  `sampleannotation` bigint(20) NOT NULL AUTO_INCREMENT,
  `idannotationtype` bigint(20) NOT NULL,
  `annotation` text,
  `description` text,
  PRIMARY KEY (`sampleannotation`,`idannotationtype`),
  KEY `idannotationtype` (`idannotationtype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sampleannotation`
--

LOCK TABLES `sampleannotation` WRITE;
/*!40000 ALTER TABLE `sampleannotation` DISABLE KEYS */;
/*!40000 ALTER TABLE `sampleannotation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sampleannotation_has_reference`
--

DROP TABLE IF EXISTS `sampleannotation_has_reference`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `sampleannotation_has_reference` (
  `sampleannotation` bigint(20) NOT NULL,
  `idreference` bigint(20) NOT NULL,
  PRIMARY KEY (`sampleannotation`,`idreference`),
  KEY `fk_sampleannotation_has_reference_sampleannotation1` (`sampleannotation`),
  KEY `fk_sampleannotation_has_reference_reference1` (`idreference`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sampleannotation_has_reference`
--

LOCK TABLES `sampleannotation_has_reference` WRITE;
/*!40000 ALTER TABLE `sampleannotation_has_reference` DISABLE KEYS */;
/*!40000 ALTER TABLE `sampleannotation_has_reference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40000 SET @saved_cs_client     = @@character_set_client */;
/*!40000 SET character_set_client = utf8 */;
CREATE TABLE `statistics` (
  `idspot` bigint(20) NOT NULL AUTO_INCREMENT,
  `supplierspotid` text,
  `value` float DEFAULT NULL,
  `p_value` float DEFAULT NULL,
  PRIMARY KEY (`idspot`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40000 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statistics`
--

LOCK TABLES `statistics` WRITE;
/*!40000 ALTER TABLE `statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `statistics` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-06-21 16:34:55
