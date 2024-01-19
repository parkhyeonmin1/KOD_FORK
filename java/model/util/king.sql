CREATE TABLE MEMBER(
	MEMBER_ID 			VARCHAR(20) 	PRIMARY KEY,
	MEMBER_PW 			VARCHAR(30) 	NOT NULL,
	MEMBER_NAME 		VARCHAR(30)		NOT NULL,
	MEMBER_PHONE 		VARCHAR(20) 	NOT NULL,
	MEMBER_EMAIL 		VARCHAR(30) 	NOT NULL UNIQUE,
	MEMBER_GRADE 		VARCHAR(20) 	NOT NULL,
	MEMBER_GENDER 		VARCHAR(10) 	NOT NULL, 
	MEMBER_BIRTH 		DATE			NOT NULL
);

CREATE TABLE PRODUCT(
	PRODUCT_ID 			INT 			PRIMARY KEY,
	PRODUCT_NAME 		VARCHAR(30)		NOT NULL UNIQUE,
	PRODUCT_BRAND 		VARCHAR(30) 	NOT NULL,
	PRODUCT_PRICE 		INT 			NOT NULL,
	PRODUCT_INFO		VARCHAR(500) 	NOT NULL,
	PRODUCT_CATEGORY 	VARCHAR(30) 	NOT NULL,
	PRODUCT_CNT			INT DEFAULT 0	NOT NULL,
	PRODUCT_IMG			VARCHAR(500)	NOT NULL
);

CREATE TABLE CART(
	CART_ID 			INT				PRIMARY KEY,
	CART_PRODUCT_CNT	INT	DEFAULT 0	NOT NULL,
	MEMBER_ID 			VARCHAR(20)		REFERENCES MEMBER(MEMBER_ID),
	PRODUCT_ID 			INT 			REFERENCES PRODUCT(PRODUCT_ID)
);

CREATE TABLE ORDERLIST( -- 주문목록
	ORDERLIST_ID 		INT				PRIMARY KEY, -- 주문번호 PK
	MEMBER_ID			VARCHAR(20)		REFERENCES MEMBER(MEMBER_ID), -- 누구의 주문목록인지
	ORDERLIST_DATE 		DATE -- 주문일자
);

CREATE TABLE ORDERCONTENT( -- 주문내역
	ORDERCONTENT_ID		INT 			PRIMARY KEY, -- 주문내용ID PK => 주문내역 속 각 상품마다 부열될 PK 값을 가진 주문내역번호
	ORDERLIST_ID		INT 			REFERENCES ORDERLIST(ORDERLIST_ID), -- 주문번호 FK
	PRODUCT_ID 			INT 			REFERENCES PRODUCT(PRODUCT_ID), -- 상품ID FK
	ORDERCONTENT_CNT	INT -- 주문한 상품수량
);

CREATE TABLE ADDRESS(
	ADDRESS_ID			INT				PRIMARY KEY, --PK
	ADDERSS_NAME		VARCHAR(30)		NOT NULL, -- 배송지이름
	ADDRRESS_STREET		VARCHAR(255)	NOT NULL, -- 도로명
	ADDRESS_LOTNUM		VARCHAR(255)	NOT NULL, -- 지번
	ADDRESS_DETAIL		VARCHAR(255)	NOT NULL, -- 상세주소
	ADDRESS_ZIPCODE		VARCHAR(20), -- 우편번호
	MEMBER_ID 			VARCHAR(20)		REFERENCES MEMBER(MEMBER_ID) -- 회원ID -> 누구의 배송지목록인지 알기위함
);

CREATE TABLE REVIEW(
	REVIEW_ID 			INT 			PRIMARY KEY,
	REVIEW_TITLE		VARCHAR(100)	NOT NULL,
	REVIEW_CONTENT		VARCHAR(500)	NOT NULL,
	REVIEW_TIME			TIMESTAMP		NOT NULL,
	REVIEW_SCORE		INT				NOT NULL,
	REVIEW_REPLY		VARCHAR(500),
	MEMBER_ID			VARCHAR(20) 	REFERENCES MEMBER(MEMBER_ID),
	PRODUCT_ID			INT 			REFERENCES PRODUCT(PRODUCT_ID)
);

CREATE TABLE WISHLIST(
	WISHLIST_ID			INT										PRIMARY KEY,
	WISHLIST_ADDTIME	TIMESTAMP DEFAULT CURRENT_TIMESTAMP		NOT NULL,
	MEMBER_ID			VARCHAR(20) 							REFERENCES MEMBER(MEMBER_ID),
	PRODUCT_ID			INT										REFERENCES PRODUCT(PRODUCT_ID),
	CONSTRAINT UNIQUE_WISHLIST_ENTRY UNIQUE(MEMBER_ID, PRODUCT_ID)
);


-- 회원별 위시리스트 
SELECT 
	M.MEMBER_NAME,
    P.PRODUCT_BRAND,
    P.PRODUCT_NAME,
    P.PRODUCT_PRICE,
    P.PRODUCT_IMG
FROM 
    WISHLIST W
JOIN 
    MEMBER M ON W.MEMBER_ID = M.MEMBER_ID
JOIN 
    PRODUCT P ON W.PRODUCT_ID = P.PRODUCT_ID
WHERE M.MEMBER_ID='teemo';


DELETE FROM WISHLIST
WHERE MEMBER_ID = 'teemo' AND WISHLIST_ID = 1;

INSERT INTO WISHLIST(WISHLIST_ID, MEMBER_ID, PRODUCT_ID)
VALUES (1, 'user', 1001);

SELECT * FROM WISHLIST WHERE MEMBER_ID='teemo';



-- 성별로 찜을 많이 한 순서
SELECT M.MEMBER_GENDER, COUNT(W.WISHLIST_ID) AS WISHLIST_COUNT
FROM MEMBER M
JOIN WISHLIST W ON M.MEMBER_ID = W.MEMBER_ID
GROUP BY M.MEMBER_GENDER
ORDER BY WISHLIST_COUNT DESC;


SELECT 
	RANK() OVER (ORDER BY COUNT(W.WISHLIST_ID) DESC) AS RANK,
	W.PRODUCT_ID, 
	M.MEMBER_GENDER, 
	COUNT(W.WISHLIST_ID) AS WISHLIST_COUNT
FROM WISHLIST W
JOIN MEMBER M ON W.MEMBER_ID = M.MEMBER_ID
WHERE M.MEMBER_GENDER = '여'
GROUP BY W.PRODUCT_ID, M.MEMBER_GENDER
ORDER BY WISHLIST_COUNT DESC;


-- 성별 찜 랭킹
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(W.WISHLIST_ID) DESC) AS RANK,
    COUNT(W.WISHLIST_ID) AS WISHLIST_COUNT,
    M.MEMBER_GENDER, 
    P.PRODUCT_BRAND,
    P.PRODUCT_NAME, -- 추가: 상품 정보
    P.PRODUCT_CATEGORY,
    P.PRODUCT_PRICE,
    P.PRODUCT_IMG
FROM WISHLIST W
JOIN MEMBER M ON W.MEMBER_ID = M.MEMBER_ID
JOIN PRODUCT P ON W.PRODUCT_ID = P.PRODUCT_ID -- 추가: 상품 테이블 조인
WHERE M.MEMBER_GENDER = '여'
GROUP BY 
    M.MEMBER_GENDER, 
    P.PRODUCT_BRAND,
    P.PRODUCT_NAME, -- 추가: 상품 정보
    P.PRODUCT_CATEGORY,
    P.PRODUCT_PRICE,
    P.PRODUCT_IMG
ORDER BY RANK;


-- 나이별 찜을 많이 한 순서
SELECT
  TRUNC(MONTHS_BETWEEN(SYSDATE, M.MEMBER_BIRTH) / 12) AS AGE,
  COUNT(W.WISHLIST_ID) AS WISHLIST_COUNT
FROM MEMBER M
JOIN WISHLIST W ON M.MEMBER_ID = W.MEMBER_ID
GROUP BY TRUNC(MONTHS_BETWEEN(SYSDATE, M.MEMBER_BIRTH) / 12)
ORDER BY WISHLIST_COUNT DESC;

-- 상품들 중 찜을 많이 한 순위
SELECT
  RANK() OVER (ORDER BY COUNT(W.WISHLIST_ID) DESC) AS RANK,
  P.PRODUCT_NAME,
  COUNT(W.WISHLIST_ID) AS WISHLIST_COUNT
FROM PRODUCT P
JOIN WISHLIST W ON P.PRODUCT_ID = W.PRODUCT_ID
GROUP BY P.PRODUCT_NAME
ORDER BY RANK;

-- 나이대별 찜을 많이 한 순위
SELECT
  CASE
    WHEN AGE >= 10 AND AGE < 20 THEN '10대'
    WHEN AGE >= 20 AND AGE < 30 THEN '20대'
    WHEN AGE >= 30 AND AGE < 40 THEN '30대'
    WHEN AGE >= 40 AND AGE < 50 THEN '40대'
    ELSE '기타'
  END AS 나이대,
  PRODUCT_NAME,
  COUNT(WISHLIST_ID) AS 총_상품_개수
FROM (
  SELECT
    ROW_NUMBER() OVER (ORDER BY COUNT(W.WISHLIST_ID) DESC) AS RANK,
    M.MEMBER_ID,
    P.PRODUCT_BRAND,
    P.PRODUCT_NAME,
    P.PRODUCT_CATEGORY,
    W.WISHLIST_ID,
    TRUNC(MONTHS_BETWEEN(SYSDATE, M.MEMBER_BIRTH) / 12) AS AGE
  FROM MEMBER M
  JOIN WISHLIST W ON M.MEMBER_ID = W.MEMBER_ID
  JOIN PRODUCT P ON W.PRODUCT_ID = P.PRODUCT_ID
) Q
WHERE AGE >= 10 AND AGE < 20 -- 10대인 멤버만 추출
GROUP BY CASE
    WHEN AGE >= 10 AND AGE < 20 THEN '10대'
    WHEN AGE >= 20 AND AGE < 30 THEN '20대'
    WHEN AGE >= 30 AND AGE < 40 THEN '30대'
    WHEN AGE >= 40 AND AGE < 50 THEN '40대'
    ELSE '기타'
  END, PRODUCT_NAME
ORDER BY COUNT(WISHLIST_ID) DESC;


