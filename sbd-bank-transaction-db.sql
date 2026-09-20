-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 20, 2026 at 05:25 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sbd_bank_16056`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `tambah_nasabah` (IN `p_id` INT, IN `p_nama` VARCHAR(100), IN `p_alamat` VARCHAR(200), IN `p_nohp` VARCHAR(20))   BEGIN
    INSERT INTO nasabah (id_nasabah, nama, alamat, no_hp)
    VALUES (p_id, p_nama, p_alamat, p_nohp);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_saldo` (IN `p_sumber` VARCHAR(20), IN `p_tujuan` VARCHAR(20), IN `p_jumlah` DECIMAL(15,2))   BEGIN
    DECLARE saldo_awal DECIMAL(15,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT saldo INTO saldo_awal
    FROM rekening
    WHERE no_rekening = p_sumber;

    IF saldo_awal >= p_jumlah THEN
        
        UPDATE rekening
        SET saldo = saldo - p_jumlah
        WHERE no_rekening = p_sumber;

        
        UPDATE rekening
        SET saldo = saldo + p_jumlah
        WHERE no_rekening = p_tujuan;

        
        INSERT INTO transaksi (tanggal, rekening_sumber, rekening_tujuan, jumlah, jenis_transaksi)
        VALUES (NOW(), p_sumber, p_tujuan, p_jumlah, 'TRANSFER');

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `cek_saldo` (`p_no_rekening` VARCHAR(20)) RETURNS DECIMAL(15,2) DETERMINISTIC BEGIN
    DECLARE saldo_rekening DECIMAL(15,2);
    SELECT saldo INTO saldo_rekening
    FROM rekening
    WHERE no_rekening = p_no_rekening;
    RETURN saldo_rekening;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_transfer` (`p_rekening` VARCHAR(20)) RETURNS DECIMAL(15,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(15,2);
    SELECT SUM(jumlah) INTO total
    FROM transaksi
    WHERE rekening_sumber = p_rekening;
    RETURN IFNULL(total, 0);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `log_transaksi`
--

CREATE TABLE `log_transaksi` (
  `id_log` int(11) NOT NULL,
  `aktivitas` varchar(255) NOT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_transaksi`
--

INSERT INTO `log_transaksi` (`id_log`, `aktivitas`, `waktu`) VALUES
(1, 'Transfer dari REK-001 ke REK-002 sebesar Rp 1.000.000,00', '2026-06-16 14:16:55');

-- --------------------------------------------------------

--
-- Table structure for table `nasabah`
--

CREATE TABLE `nasabah` (
  `id_nasabah` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(200) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nasabah`
--

INSERT INTO `nasabah` (`id_nasabah`, `nama`, `alamat`, `no_hp`) VALUES
(1, 'Budi Santoso', 'Jl. Merdeka No.1, Jakarta', '08111111111'),
(2, 'Siti Rahayu', 'Jl. Sudirman No.5, Bandung', '08222222222'),
(3, 'Agus Prasetyo', 'Jl. Diponegoro No.9, Surabaya', '08333333333');

-- --------------------------------------------------------

--
-- Table structure for table `rekening`
--

CREATE TABLE `rekening` (
  `no_rekening` varchar(20) NOT NULL,
  `id_nasabah` int(11) NOT NULL,
  `jenis_rekening` varchar(30) NOT NULL DEFAULT 'TABUNGAN',
  `saldo` decimal(15,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rekening`
--

INSERT INTO `rekening` (`no_rekening`, `id_nasabah`, `jenis_rekening`, `saldo`) VALUES
('REK-001', 1, 'TABUNGAN', 4000000.00),
('REK-002', 2, 'TABUNGAN', 4000000.00),
('REK-003', 3, 'GIRO', 10000000.00);

--
-- Triggers `rekening`
--
DELIMITER $$
CREATE TRIGGER `before_update_saldo` BEFORE UPDATE ON `rekening` FOR EACH ROW BEGIN
    IF NEW.saldo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo tidak boleh negatif';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `tanggal` datetime NOT NULL,
  `rekening_sumber` varchar(20) NOT NULL,
  `rekening_tujuan` varchar(20) NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `jenis_transaksi` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id_transaksi`, `tanggal`, `rekening_sumber`, `rekening_tujuan`, `jumlah`, `jenis_transaksi`) VALUES
(1, '2026-06-16 21:16:55', 'REK-001', 'REK-002', 1000000.00, 'TRANSFER');

--
-- Triggers `transaksi`
--
DELIMITER $$
CREATE TRIGGER `after_insert_transaksi` AFTER INSERT ON `transaksi` FOR EACH ROW BEGIN
    INSERT INTO log_transaksi (aktivitas, waktu)
    VALUES (
        CONCAT('Transfer dari ', NEW.rekening_sumber,
               ' ke ', NEW.rekening_tujuan,
               ' sebesar Rp ', FORMAT(NEW.jumlah, 2, 'id_ID')),
        NOW()
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_bank`
--

CREATE TABLE `user_bank` (
  `id_user` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `log_transaksi`
--
ALTER TABLE `log_transaksi`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `nasabah`
--
ALTER TABLE `nasabah`
  ADD PRIMARY KEY (`id_nasabah`);

--
-- Indexes for table `rekening`
--
ALTER TABLE `rekening`
  ADD PRIMARY KEY (`no_rekening`),
  ADD KEY `fk_rekening_nasabah` (`id_nasabah`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `fk_transaksi_sumber` (`rekening_sumber`),
  ADD KEY `fk_transaksi_tujuan` (`rekening_tujuan`);

--
-- Indexes for table `user_bank`
--
ALTER TABLE `user_bank`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `log_transaksi`
--
ALTER TABLE `log_transaksi`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_bank`
--
ALTER TABLE `user_bank`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `rekening`
--
ALTER TABLE `rekening`
  ADD CONSTRAINT `fk_rekening_nasabah` FOREIGN KEY (`id_nasabah`) REFERENCES `nasabah` (`id_nasabah`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `fk_transaksi_sumber` FOREIGN KEY (`rekening_sumber`) REFERENCES `rekening` (`no_rekening`),
  ADD CONSTRAINT `fk_transaksi_tujuan` FOREIGN KEY (`rekening_tujuan`) REFERENCES `rekening` (`no_rekening`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
