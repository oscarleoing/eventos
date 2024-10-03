
use Eventos

CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    CorreoElectronico VARCHAR(100),
    Contraseña VARCHAR(100),
    Telefono VARCHAR(20)
);

CREATE TABLE Eventos (
    IdEvento INT IDENTITY(1,1) PRIMARY KEY, 
    NombreEvento VARCHAR(200),
    Fecha DATETIME,
    Descripcion TEXT,
    Ubicacion VARCHAR(200)
);

CREATE TABLE Escenarios (
    IdEscenario INT IDENTITY(1,1) PRIMARY KEY,
    NombreEscenario VARCHAR(200),
    Capacidad INT,
    IdEvento INT,
    FOREIGN KEY (IdEvento) REFERENCES Eventos(IdEvento)
);

CREATE TABLE Asientos (
    IdAsiento INT IDENTITY(1,1) PRIMARY KEY,
    NumeroAsiento VARCHAR(10) NOT NULL,  -- Número del asiento (ej. 'A1')
    Seccion VARCHAR(50),                -- Sección del escenario (ej. 'VIP')
    Fila VARCHAR(10),                   -- Fila del asiento (ej. '1')
    Columna INT,                        -- Columna del asiento
    Disponible BIT NOT NULL DEFAULT 1,  -- Disponibilidad del asiento (1 = Disponible, 0 = Ocupado)
    IdEscenario INT,                    -- ID del escenario (clave foránea)
    NombreReserva VARCHAR(100) NULL,    -- Nombre del usuario que reservó el asiento
    FOREIGN KEY (IdEscenario) REFERENCES Escenarios(IdEscenario) , -- Clave foránea a la tabla Escenarios,
	Folio INT
);

CREATE TABLE Reservas (
    IdReserva INT IDENTITY(1,1) PRIMARY KEY,
    NombreReserva VARCHAR(100),  -- Nombre del usuario que realizó la reserva
    CantidadAsientos INT,        -- Número de asientos seleccionados
    NombreAsientosSeleccionados VARCHAR(MAX),  -- Nombres de los asientos seleccionados (ej. A1, B2)
    IdAsientosSeleccionados VARCHAR(MAX),  -- IDs de los asientos seleccionados como una cadena separada por comas (ej. '1,2,3')
    FechaReserva DATETIME,       -- Fecha de la reserva
    IdUsuario INT,               -- ID del usuario que realizó la reserva (clave foránea)
    FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)  -- Clave foránea a la tabla Usuarios
);



	SELECT * FROM Usuarios 

	SELECT * FROM Asientos

	SELECT * FROM Reservas

	SELECT * FROM Escenarios

	SELECT * FROM Eventos

INSERT INTO Usuarios (Nombre, CorreoElectronico, Contraseña, Telefono)
VALUES ('Juan Pérez', 'juan.perez@ejemplo.com', 'password123', '555-1234');

INSERT INTO Eventos (NombreEvento, Fecha, Descripcion, Ubicacion)
VALUES ('Nombre del Evento', '2024-09-15 20:00:00', 'Descripcion del evento', 'Lugar del Evento');

INSERT INTO Escenarios (NombreEscenario, Capacidad, IdEvento)
VALUES ('Escenario Principal', 1000, 1);  -- Reemplaza '1' con el IdEvento correcto

INSERT INTO Escenarios (NombreEscenario, Capacidad, IdEvento)
VALUES ('Primer piso', 1000, 1);  -- Reemplaza '1' con el IdEvento correcto




		create proc sp_lista_asientos
as
begin
	select 
	IdAsiento,NumeroAsiento,Seccion,
	Fila,Columna,Disponible,IdEscenario,NombreReserva
	from Asientos
end

go

exec sp_lista_asientos





	DECLARE @fila CHAR(1)
DECLARE @columna INT
DECLARE @limite INT
DECLARE @sql NVARCHAR(MAX) = ''

-- Tabla temporal que contiene el número máximo de columnas por fila
DECLARE @Limites TABLE (
    Fila CHAR(1),
    MaxColumnas INT
)

-- Insertar los límites de las columnas para cada fila
INSERT INTO @Limites (Fila, MaxColumnas) VALUES
('A', 28), ('B', 32), ('C', 34), ('D', 38), ('E', 42),
('F', 44), ('G', 44), ('H', 44), ('I', 44), ('J', 46),
('K', 46), ('L', 46), ('M', 46), ('N', 46), ('Ñ', 48),
('O', 48), ('P', 44), ('Q', 45), ('R', 49), ('S', 45),
('T', 45), ('U', 47), ('V', 45), ('W', 46)

-- Itera por las filas de A a W
DECLARE @row CHAR(1)
SET @row = 'A'

WHILE @row <= 'W'
BEGIN
    -- Obtener el número máximo de columnas para la fila actual
    SELECT @limite = MaxColumnas FROM @Limites WHERE Fila = @row

    -- Iterar por las columnas según el límite definido
    SET @columna = 1
    WHILE @columna <= @limite
    BEGIN
        -- Genera la instrucción INSERT para cada fila y columna
        SET @sql = @sql + 'INSERT INTO Asientos (NumeroAsiento, Seccion, Fila, Columna, Disponible, IdEscenario) ' +
                    'VALUES (''' + @row + CAST(@columna AS VARCHAR) + ''', ''Escenario Principal'', ''' + @row + ''', ' + CAST(@columna AS VARCHAR) + ', 1, 1);' + CHAR(13)

        SET @columna = @columna + 1
    END

    -- Incrementa la fila (de A a B, B a C, ..., W)
    SET @row = CHAR(ASCII(@row) + 1)
END

-- Ejecuta el script generado
EXEC sp_executesql @sql




DECLARE @fila CHAR(1)
DECLARE @columna INT
DECLARE @limiteColumna INT
DECLARE @sql NVARCHAR(MAX) = ''

-- Array de filas desde A hasta Ñ (puedes agregar más filas si es necesario)
DECLARE @filas TABLE (Fila CHAR(1))
INSERT INTO @filas (Fila)
VALUES ('Ñ')

-- Iterar sobre cada fila y columna
DECLARE @row CHAR(1)
DECLARE fila_cursor CURSOR FOR SELECT Fila FROM @filas
OPEN fila_cursor

FETCH NEXT FROM fila_cursor INTO @row

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Establecer el límite de columnas según la fila
    IF @row = 'Ñ'
        SET @limiteColumna = 48  -- Para la fila Ñ, solo hasta la columna 48
    ELSE
        SET @limiteColumna = 50  -- Para otras filas, hasta la columna 50

    -- Iterar sobre las columnas hasta el límite correspondiente
    SET @columna = 1
    WHILE @columna <= @limiteColumna
    BEGIN
        -- Generar la instrucción INSERT
        SET @sql = @sql + 'INSERT INTO Asientos (NumeroAsiento, Seccion, Fila, Columna, Disponible, IdEscenario) ' +
                    'VALUES (''' + @row + CAST(@columna AS VARCHAR) + ''', ''Escenario Principal'', ''' + @row + ''', ' + CAST(@columna AS VARCHAR) + ', 1, 1);' + CHAR(13)

        SET @columna = @columna + 1
    END

    -- Obtener la siguiente fila
    FETCH NEXT FROM fila_cursor INTO @row
END

CLOSE fila_cursor
DEALLOCATE fila_cursor

-- Ejecutar el script generado
EXEC sp_executesql @sql



DECLARE @fila CHAR(2)
DECLARE @columna INT
DECLARE @limiteColumna INT
DECLARE @sql NVARCHAR(MAX) = ''

-- Tabla temporal que contiene el número máximo de columnas por fila
DECLARE @Limites TABLE (
    Fila CHAR(2),
    MaxColumnas INT
)

-- Insertar los límites de las columnas para cada fila
INSERT INTO @Limites (Fila, MaxColumnas) VALUES
('AA', 39), ('BB', 40), ('CC', 42), ('DD', 43), ('EE', 44),
('FF', 44), ('GG', 44), ('HH', 45), ('II', 39), ('JJ', 38), ('KK', 41)

-- Iterar sobre cada fila
DECLARE @row CHAR(2)
DECLARE fila_cursor CURSOR FOR SELECT Fila, MaxColumnas FROM @Limites -- Seleccionar ambas columnas
OPEN fila_cursor

FETCH NEXT FROM fila_cursor INTO @row, @limiteColumna -- Asignar ambas columnas a las variables

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Iterar sobre las columnas hasta el límite definido para cada fila
    SET @columna = 1
    WHILE @columna <= @limiteColumna
    BEGIN
        -- Generar la instrucción INSERT para cada combinación de fila y columna
        SET @sql = @sql + 'INSERT INTO Asientos (NumeroAsiento, Seccion, Fila, Columna, Disponible, IdEscenario) ' +
                    'VALUES (''' + @row + CAST(@columna AS VARCHAR) + ''', ''Primer piso'', ''' + @row + ''', ' + CAST(@columna AS VARCHAR) + ', 1, 2);' + CHAR(13)

        SET @columna = @columna + 1
    END

    -- Obtener la siguiente fila
    FETCH NEXT FROM fila_cursor INTO @row, @limiteColumna -- Seleccionar ambas columnas nuevamente
END

CLOSE fila_cursor
DEALLOCATE fila_cursor

-- Ejecutar el script generado
EXEC sp_executesql @sql




CREATE PROCEDURE sp_ComprarBoletos
    @IdUsuario INT,
    @NombreReserva VARCHAR(100),  -- El nombre de la reserva se pasa como parámetro
    @AsientosIds VARCHAR(MAX),  -- Cadena de IDs de Asientos separada por comas
    @FechaReserva DATETIME
AS
BEGIN
    -- Iniciar una transacción para asegurar la integridad de los datos
    BEGIN TRANSACTION;

    -- Convertir la cadena de IDs de asientos en una tabla temporal
    DECLARE @IdsTabla TABLE (IdAsiento INT);

    INSERT INTO @IdsTabla (IdAsiento)
    SELECT value FROM STRING_SPLIT(@AsientosIds, ',');

    -- Verificar que todos los asientos estén disponibles
    IF EXISTS (SELECT 1 FROM Asientos WHERE IdAsiento IN (SELECT IdAsiento FROM @IdsTabla) AND Disponible = 0)
    BEGIN
        -- Revertir la transacción si algún asiento no está disponible
        ROLLBACK TRANSACTION;
        PRINT 'Uno o más asientos no están disponibles.';
    END
    ELSE
    BEGIN
        -- Insertar un único registro en la tabla Reservas
        INSERT INTO Reservas (NombreReserva, CantidadAsientos, NombreAsientosSeleccionados, IdUsuario, FechaReserva, IdAsientosSeleccionados)
        VALUES (
            @NombreReserva,  -- Usar el nombre de la reserva proporcionado
            (SELECT COUNT(*) FROM @IdsTabla), 
            (SELECT STRING_AGG(NumeroAsiento, ', ') FROM Asientos WHERE IdAsiento IN (SELECT IdAsiento FROM @IdsTabla)), 
            @IdUsuario, 
            @FechaReserva,
            @AsientosIds
        );

        -- Actualizar el estado de los asientos a no disponibles y asignar el nombre de la reserva
        UPDATE Asientos
        SET Disponible = 0, NombreReserva = @NombreReserva  -- Usar el nombre de la reserva proporcionado
        WHERE IdAsiento IN (SELECT IdAsiento FROM @IdsTabla);

        -- Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Boletos comprados con éxito.';
    END
END;


CREATE PROCEDURE sp_EditarReserva
    @IdReserva INT,               -- ID de la reserva a editar
    @NombreReserva VARCHAR(100),  -- Nuevo nombre de la reserva
    @NombresAsientos VARCHAR(MAX),-- Cadena de nombres de Asientos separada por comas
    @FechaReserva DATETIME        -- Nueva fecha de la reserva
AS
BEGIN
    -- Iniciar una transacción para asegurar la integridad de los datos
    BEGIN TRANSACTION;

    -- Convertir la cadena de nombres de asientos en una tabla temporal
    DECLARE @NombresTabla TABLE (NumeroAsiento VARCHAR(10));
    INSERT INTO @NombresTabla (NumeroAsiento)
    SELECT value FROM STRING_SPLIT(@NombresAsientos, ',');

    -- Obtener los nombres de los asientos anteriores de la reserva
    DECLARE @AsientosAnteriores VARCHAR(MAX);
    SELECT @AsientosAnteriores = NombreAsientosSeleccionados FROM Reservas WHERE IdReserva = @IdReserva;

    -- Marcar los asientos anteriores como disponibles
    UPDATE Asientos
    SET Disponible = 1, NombreReserva = NULL
    WHERE NumeroAsiento IN (SELECT value FROM STRING_SPLIT(@AsientosAnteriores, ','));

    -- Verificar si los nuevos asientos están disponibles
    IF EXISTS (SELECT 1 FROM Asientos WHERE NumeroAsiento IN (SELECT NumeroAsiento FROM @NombresTabla) AND Disponible = 0)
    BEGIN
        -- Revertir la transacción si algún asiento no está disponible
        ROLLBACK TRANSACTION;
        PRINT 'Uno o más asientos no están disponibles.';
    END
    ELSE
    BEGIN
        -- Actualizar la reserva con el nuevo nombre, fecha y asientos
        UPDATE Reservas
        SET NombreReserva = @NombreReserva,
            CantidadAsientos = (SELECT COUNT(*) FROM @NombresTabla),
            NombreAsientosSeleccionados = @NombresAsientos,
            FechaReserva = @FechaReserva
        WHERE IdReserva = @IdReserva;

        -- Marcar los nuevos asientos como no disponibles y asignarles el nombre de la reserva
        UPDATE Asientos
        SET Disponible = 0, NombreReserva = @NombreReserva
        WHERE NumeroAsiento IN (SELECT NumeroAsiento FROM @NombresTabla);

        -- Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Reserva editada con éxito.';
    END
END;


	SELECT * FROM Asientos

	SELECT * FROM Reservas