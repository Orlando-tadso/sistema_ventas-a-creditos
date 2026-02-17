-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-02-2026 a las 03:54:18
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
  `direccion` varchar(200) DEFAULT NULL,
  `dni` varchar(20) DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL DEFAULT 0.00,
  `nota` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
,`direccion` varchar(200)
,`dni` varchar(20)
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
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `email`, `password`, `rol`, `activo`, `fecha_registro`, `ultimo_acceso`) VALUES
(1, 'Administrador', 'admin@tienda.com', '$2y$10$iTQoN2OalY2LHsTocVpMEe5jJYN78qgeDQMsp5EW7Qdiw7HzJ0oP.', 'admin', 1, '2026-02-14 16:43:54', '2026-02-17 02:42:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_credito`
--

CREATE TABLE `ventas_credito` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL DEFAULT 0.00,
  `descripcion` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura para la vista `saldo_clientes`
--
DROP TABLE IF EXISTS `saldo_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `saldo_clientes`  AS SELECT `c`.`id` AS `id`, `c`.`nombre` AS `nombre`, `c`.`apellido` AS `apellido`, `c`.`telefono` AS `telefono`, `c`.`direccion` AS `direccion`, `c`.`dni` AS `dni`, `c`.`fecha_registro` AS `fecha_registro`, `c`.`activo` AS `activo`, coalesce(sum(`v`.`monto`),0) AS `total_debe`, coalesce(sum(`p`.`monto`),0) AS `total_pago`, coalesce(sum(`v`.`monto`),0) - coalesce(sum(`p`.`monto`),0) AS `saldo_actual` FROM ((`clientes` `c` left join `ventas_credito` `v` on(`c`.`id` = `v`.`cliente_id`)) left join `pagos` `p` on(`c`.`id` = `p`.`cliente_id`)) GROUP BY `c`.`id`, `c`.`nombre`, `c`.`apellido`, `c`.`telefono`, `c`.`direccion`, `c`.`dni`, `c`.`fecha_registro`, `c`.`activo` ;

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
  ADD KEY `idx_telefono` (`telefono`),
  ADD KEY `idx_dni` (`dni`),
  ADD KEY `idx_activo` (`activo`),
  ADD KEY `idx_nombre_activo` (`nombre`,`activo`),
  ADD KEY `idx_apellido_activo` (`apellido`,`activo`),
  ADD KEY `idx_nombre_apellido` (`nombre`,`apellido`);
ALTER TABLE `clientes` ADD FULLTEXT KEY `idx_fulltext_nombre` (`nombre`,`apellido`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cliente_id` (`cliente_id`),
  ADD KEY `idx_fecha` (`fecha`),
  ADD KEY `idx_cliente_fecha` (`cliente_id`,`fecha`),
  ADD KEY `idx_usuario_id` (`usuario_id`);

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
  ADD KEY `idx_cliente_id` (`cliente_id`),
  ADD KEY `idx_fecha` (`fecha`),
  ADD KEY `idx_cliente_fecha` (`cliente_id`,`fecha`),
  ADD KEY `idx_usuario_id` (`usuario_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pagos_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ventas_credito`
--
ALTER TABLE `ventas_credito`
  ADD CONSTRAINT `ventas_credito_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ventas_credito_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
