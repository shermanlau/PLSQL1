PL/SQL1
======

--QUESTION 1--
--CREATE PROCEDURE--
CREATE OR REPLACE PROCEDURE TAX_COST_SP(
    stateName IN BB_TAX.STATE%TYPE,
    subTotal  IN NUMBER,
    taxAmount OUT NUMBER)
IS
BEGIN
  SELECT taxRate INTO taxAmount FROM BB_TAX WHERE state = stateName;
  taxAmount := taxAmount*subTotal;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  taxAmount := 0;
END;

-----EXECUTE PROCEDURE------
SET SERVEROUTPUT ON
DECLARE
  G_TAX NUMBER;
BEGIN
  TAX_COST_SP('VA',100,G_TAX);
  DBMS_OUTPUT.PUT_LINE('TAX AMOUNT :$'|| G_TAX);
END;

--QUESTION 2--
--CREATE PROCEDURE--
CREATE OR REPLACE PROCEDURE STATUS_SHIP_SP
(p_basket IN BB_BASKETSTATUS.IDBASKET%TYPE,
p_date IN BB_BASKETSTATUS.DTSTAGE%TYPE,
p_shipper IN BB_BASKETSTATUS.SHIPPER%TYPE,
p_tracking IN BB_BASKETSTATUS.SHIPPINGNUM%TYPE)
IS
BEGIN
INSERT INTO BB_BASKETSTATUS(IDSTATUS,IDBASKET, IDSTAGE, DTSTAGE,SHIPPER, SHIPPINGNUM )
VALUES (BB_STATUS_SEQ.NEXTVAL, p_basket ,3, p_date, p_shipper, p_tracking);
DBMS_OUTPUT.PUT_LINE(' Inserted '|| SQL%ROWCOUNT
||' row ');
END STATUS_SHIP_SP;
-----EXECUTE PROCEDURE------
set SERVEROUTPUT on
begin
 STATUS_SHIP_SP (3, '20-FEB-03','UPS','ZW2384YXK4957');
end;

--QUESTION 3--
--CREATE PROCEDURE--
 CREATE OR REPLACE PROCEDURE PROMO_SHIP_SP(
    v_cutoffDate IN BB_BASKET.DTCREATED%TYPE ,
    v_endMonth   IN BB_PROMOLIST.MONTH%TYPE,
    v_endYear IN BB_PROMOLIST.YEAR%TYPE)
IS
BEGIN
  FOR rec_shoppers IN
  (SELECT IDSHOPPER FROM BB_BASKET WHERE (TO_DATE(ADD_MONTHS(DTCREATED,2),'DD/MM/RR')<v_cutoffDate))
  LOOP
    INSERT INTO bb_promolist values
      (rec_shoppers.IDSHOPPER,v_endMonth,v_endYear,'1','N');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('BB_PROMOLIST updated !!');
END;

-----EXECUTE PROCEDURE------
set SERVEROUTPUT on
BEGIN
  PROMO_SHIP_SP('15-FEB-03','APR','2003');
END;

--QUESTION 4--
--CREATE FUNCTION--
CREATE OR REPLACE FUNCTION TOT_PURCH_SF (p_id  BB_BASKET.IDSHOPPER%TYPE) 
RETURN NUMBER IS
v_total BB_BASKET.TOTAL%TYPE;
BEGIN

SELECT SUM(TOTAL)INTO v_total FROM BB_BASKET WHERE BB_BASKET.IDSHOPPER=p_id;

RETURN v_total;
END;

-----EXECUTE------

SELECT IDSHOPPER,TOT_PURCH_SF(BB_SHOPPER.IDSHOPPER) FROM BB_SHOPPER; 

--QUESTION 5--
--CREATE FUNCTION--
CREATE OR REPLACE FUNCTION ORD_SHIP_SF(v_basketid NUMBER)
  RETURN VARCHAR2
IS
  v_statusString VARCHAR2(50);
  v_dateDiff     NUMBER;
BEGIN
    SELECT (bb_basketstatus.dtstage-bb_basket.dtcreated)
    INTO v_dateDiff
    FROM bb_basket
    JOIN bb_basketstatus
    ON bb_basket.idbasket = bb_basketstatus.idbasket
    WHERE  bb_basket.idbasket=v_basketid AND bb_basketstatus.idstage=5;
    IF v_dateDiff>1 THEN
      v_statusString := 'CHECK';
    ELSE
      v_statusString := 'OK';
    END IF;
    RETURN v_statusString;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_statusString := 'NO SUCH BASKET';
    RETURN v_statusString;
END;
-----EXECUTE------

select ORD_SHIP_SF(3) from dual;

--QUESTION 6--
SET serveroutput ON
DECLARE
  g_new               NUMBER := 4;
  g_old               NUMBER := 30;
  counter             NUMBER := 0;
  invalid_og_basketid EXCEPTION;
BEGIN
  SELECT COUNT(*) INTO counter FROM BB_BASKETITEM WHERE IDBASKET = g_old;
  IF counter = 0 THEN
    raise invalid_og_basketid;
  ELSE
    UPDATE bb_basketitem SET idBasket = g_new WHERE idBasket = g_old;
  END IF;
EXCEPTION
WHEN invalid_og_basketid THEN
  DBMS_OUTPUT.PUT_LINE('Invalid original Basket ID');
END;

