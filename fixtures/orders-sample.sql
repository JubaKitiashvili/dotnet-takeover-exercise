-- სრულად გამოგონილი ილუსტრაცია; გაშვება სავალდებულო არაა.
-- მხოლოდ table variable: მუდმივი ობიექტები და გარე კავშირები არ იქმნება.
-- ეს 7 ჩანაწერი არ წარმოადგენს 8-მილიონიანი ცხრილის დატვირთვას ან skew-ს.
-- დავალების რეალური ზომის გამოგონილი სქემა:
-- dbo.Orders: OrderId clustered PK; CreatedAt datetime2 UTC;
-- IX_Orders_Tenant_CreatedAt(TenantId, CreatedAt) INCLUDE(Status).
-- აქ ინდექსი/locking/performance არ მოდელირდება.

DECLARE @TenantId int = 42;
DECLARE @Day date = '20261006'; -- UTC კალენდარული დღე
DECLARE @Orders TABLE (
    OrderId bigint NOT NULL,
    TenantId int NOT NULL,
    Status nvarchar(20) NOT NULL,
    CreatedAt datetime2(0) NOT NULL
);

INSERT INTO @Orders (OrderId, TenantId, Status, CreatedAt)
VALUES
    (7000097, 42, N'Closed',     '2026-10-05T23:59:59'),
    (7000098, 42, N'New',        '2026-10-06T00:00:00'),
    (7000099, 42, N'Queued',     '2026-10-06T09:00:00'),
    (7000100, 42, N'New',        '2026-10-06T10:01:00'),
    (7000101, 42, N'InProgress', '2026-10-06T10:05:00'),
    (7000102, 77, N'New',        '2026-10-06T10:06:00'),
    (7000103, 42, N'New',        '2026-10-06T10:09:10');

-- თავდაპირველი query; მხოლოდ FROM იყენებს @Orders-ს dbo.Orders-ის ნაცვლად.
-- ეს საწყისი მაგალითია და არა შემოთავაზებული გაუმჯობესება.
SELECT OrderId, Status, CreatedAt
FROM @Orders
WHERE TenantId = @TenantId
  AND CONVERT(date, CreatedAt) = @Day
ORDER BY CreatedAt DESC;
