CREATE TABLE [dbo].[Void_Lock] (
    [Id]              CHAR (36)    NOT NULL,
    [BuyerIP]         VARCHAR (15) NULL,
    [CreateTimestamp] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PK__transact__3214EC07ECD4C65C]
    ON [dbo].[Void_Lock]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [RangeDateTimeIdx1]
    ON [dbo].[Void_Lock]([CreateTimestamp] ASC);

