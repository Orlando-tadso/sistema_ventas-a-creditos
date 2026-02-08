-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-02-2026 a las 20:41:00
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `tienda_credito`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `apellido`, `telefono`, `direccion`, `fecha_registro`, `activo`) VALUES
(1, 'Juan', 'P??rez', '555-1234', 'Calle Principal 123', '2026-02-08 18:46:40', 0),
(2, 'Mar??a', 'Garc??a', '555-5678', 'Avenida Central 456', '2026-02-08 18:46:40', 0),
(3, 'Carlos', 'L??pez', '555-9012', 'Barrio Norte 789', '2026-02-08 18:46:40', 0),
(4, 'orlando', 'baldovino', '3505630633', 'bbbbbbbbbbbbbb', '2026-02-08 19:01:19', 1),
(5, 'qqqqqqqqqqqqqqq', 'qqqqqqq', '3229139965', 'vvdsarseczbdg', '2026-02-08 19:11:21', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `venta_id` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `nota` text DEFAULT NULL
) ;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id`, `cliente_id`, `venta_id`, `monto`, `fecha`, `nota`) VALUES
(1, 4, NULL, 50000.00, '2026-02-08 19:07:04', 'Pago de prueba directa'),
(2, 4, NULL, 30000.00, '2026-02-08 19:10:39', ''),
(3, 5, NULL, 599000.00, '2026-02-08 19:13:11', '');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `saldo_clientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `saldo_clientes` (
`id` int(11)
,`nombre` varchar(100)
,`apellido` varchar(100)
,`telefono` varchar(20)
,`direccion` text
,`fecha_registro` timestamp
,`activo` tinyint(1)
,`total_debe` decimal(32,2)
,`total_pago` decimal(32,2)
,`saldo_actual` decimal(33,2)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol` enum('admin','vendedor') DEFAULT 'vendedor',
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `email`, `password`, `rol`, `activo`, `fecha_creacion`, `ultimo_acceso`) VALUES
(1, 'Administrador', 'admin@tienda.com', '$2y$10$uTljZGTL1jgOeIm0WiUjCux7STkPgUaMb2GHsC6Ns3zdPOawq89k2', 'admin', 1, '2026-02-08 18:46:39', '2026-02-08 19:13:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_credito`
--

CREATE TABLE `ventas_credito` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `pago_completo` tinyint(1) DEFAULT 0
) ;

--
-- Volcado de datos para la tabla `ventas_credito`
--

INSERT INTO `ventas_credito` (`id`, `cliente_id`, `monto`, `descripcion`, `fecha`, `pago_completo`) VALUES
(1, 3, 30000.00, '', '2026-02-08 18:49:38', 0),
(2, 4, 100000.00, '', '2026-02-08 19:01:37', 0),
(3, 5, 300000.00, '', '2026-02-08 19:12:09', 0),
(4, 5, 300000.00, '', '2026-02-08 19:12:21', 0);

-- --------------------------------------------------------

--
-- Estructura para la vista `saldo_clientes`
--
DROP TABLE IF EXISTS `saldo_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `saldo_clientes`  AS SELECT `c`.`id` AS `id`, `c`.`nombre` AS `nombre`, `c`.`apellido` AS `apellido`, `c`.`telefono` AS `telefono`, `c`.`direccion` AS `direccion`, `c`.`fecha_registro` AS `fecha_registro`, `c`.`activo` AS `activo`, coalesce(`v`.`total_debe`,0) AS `total_debe`, coalesce(`p`.`total_pago`,0) AS `total_pago`, coalesce(`v`.`total_debe`,0) - coalesce(`p`.`total_pago`,0) AS `saldo_actual` FROM ((`clientes` `c` left join (select `ventas_credito`.`cliente_id` AS `cliente_id`,sum(`ventas_credito`.`monto`) AS `total_debe` from `ventas_credito` group by `ventas_credito`.`cliente_id`) `v` on(`c`.`id` = `v`.`cliente_id`)) left join (select `pagos`.`cliente_id` AS `cliente_id`,sum(`pagos`.`monto`) AS `total_pago` from `pagos` group by `pagos`.`cliente_id`) `p` on(`c`.`id` = `p`.`cliente_id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nombre` (`nombre`),
  ADD KEY `idx_apellido` (`apellido`),
  ADD KEY `idx_activo` (`activo`),
  ADD KEY `idx_telefono` (`telefono`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cliente` (`cliente_id`),
  ADD KEY `idx_fecha` (`fecha`),
  ADD KEY `idx_venta` (`venta_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_activo` (`activo`);

--
-- Indices de la tabla `ventas_credito`
--
ALTER TABLE `ventas_credito`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cliente` (`cliente_id`),
  ADD KEY `idx_fecha` (`fecha`),
  ADD KEY `idx_pago_completo` (`pago_completo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `ventas_credito`
--
ALTER TABLE `ventas_credito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pagos_ibfk_2` FOREIGN KEY (`venta_id`) REFERENCES `ventas_credito` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `ventas_credito`
--
ALTER TABLE `ventas_credito`
  ADD CONSTRAINT `ventas_credito_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
