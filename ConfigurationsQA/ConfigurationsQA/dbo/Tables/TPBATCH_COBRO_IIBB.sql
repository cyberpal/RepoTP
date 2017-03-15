CREATE TABLE [dbo].[TPBATCH_COBRO_IIBB] (
    [codprov]   CHAR (2)        NOT NULL,
    [idret]     CHAR (9)        NOT NULL,
    [numret]    CHAR (20)       NULL,
    [codcliext] CHAR (15)       NULL,
    [cuit]      CHAR (15)       NULL,
    [razsoc]    CHAR (50)       NULL,
    [direcc]    CHAR (200)      NULL,
    [local]     CHAR (20)       NULL,
    [nroib]     CHAR (13)       NULL,
    [regimen]   CHAR (100)      NULL,
    [fecpag]    CHAR (10)       NULL,
    [baseimp]   NUMERIC (12, 2) NULL,
    [alicuota]  NUMERIC (12, 2) NULL,
    [impret]    NUMERIC (12, 2) NULL,
    CONSTRAINT [PK_TPBATCH_COBRO_IIBB] PRIMARY KEY CLUSTERED ([codprov] ASC, [idret] ASC)
);

