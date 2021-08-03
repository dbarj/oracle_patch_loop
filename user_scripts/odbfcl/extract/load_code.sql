WHENEVER SQLERROR EXIT SQL.SQLCODE

-- TODO: CHANGE 2 QUERIES FOR 1 USING "INSERT ALL"

insert /*+ append */
  into DM_CODES (MD5_HASH, CODE, WRAPPED)
select MD5_ENC,
       CODE,
       CASE
        WHEN REGEXP_INSTR(CODE, 'wrapped', 1, 1, 0, 'i') > 0
         AND REGEXP_INSTR(CODE, 'abcd', 1, 1, 0, 'i') > 0
        THEN 'Y'
        ELSE 'N'
        END WRAPPED
from (
    select MD5_ENC,
           CODE,
           RANK() over (partition by MD5_ENC order by rowid asc) col_ind
    from T_HASH_LOAD
)
where col_ind=1;

insert /*+ append */
  into T_HASH (OWNER, NAME, TYPE, ORIGIN_CON_ID, CON_ID, MD5_ENC, SHA1_ENC, ORAVERSION, ORASERIES, ORAPATCH)
select OWNER,
       NAME,
       TYPE,
       ORIGIN_CON_ID,
       CON_ID,
       MD5_ENC,
       SHA1_ENC,
       '&P_VERS.' oraversion,
       '&P_SER.'  oraseries,
       &P_PATCH.  orapatch
from T_HASH_LOAD;

commit;

drop table T_HASH_LOAD purge;

---------------------------------------------
------------    SECTION START    ------------
------------ UNWRAP WRAPPED CODE ------------
---------------------------------------------

set def ^

create or replace java source named CUX_UNWRAPPER
as
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.Reader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.zip.Deflater;
import java.util.zip.InflaterInputStream;
import oracle.jdbc.OracleDriver;
import oracle.sql.CLOB;

public class UNWRAPPER {
         //unzip
    public static CLOB Inflate(CLOB src) throws IOException, SQLException {
        StringBuffer sb = new StringBuffer();
        String s = src.stringValue();
         try{
        ByteArrayInputStream bis =
            new ByteArrayInputStream(decodeHex(s.toCharArray()));
        //ByteArrayInputStream bis = new ByteArrayInputStream(src);
        InflaterInputStream iis = new InflaterInputStream(bis);
        for (int c = iis.read(); c != -1; c = iis.read()) {
            sb.append((char)c);
        }
        }catch (Exception e)
        {
           e.printStackTrace();
        }

        Connection conn = DriverManager.getConnection("jdbc:default:connection:");
        CLOB clob =  CLOB.createTemporary(conn, false, CLOB.DURATION_SESSION);
        clob.setString(1, sb.toString());
        return clob;

    }

    public static byte[] Deflate(String src, int quality) {
        try {
            byte[] tmp = new byte[src.length() + 100];
            Deflater defl = new Deflater(quality);
            defl.setInput(src.getBytes("UTF-8"));
            defl.finish();
            int cnt = defl.deflate(tmp);
            byte[] res = new byte[cnt];
            for (int i = 0; i < cnt; i++)
                res = tmp;
            return res;
        } catch (Exception e) {
        }
        return null;
    }

    public static int toDigit(char ch, int index) {
        int digit = Character.digit(ch, 16);
        if (digit == -1) {
            throw new RuntimeException("illegal hexadecimal character " + ch +
                                       " at index " + index);
        }
        return digit;
    }

         //16-ary string to byte array
    public static byte[] decodeHex(char[] data) {
        int len = data.length;
        if ((len & 0x01) != 0) {
            throw new RuntimeException("odd  number of characters ");
        }

        byte[] out = new byte[len >> 1];

        for (int i = 0, j = 0; j < len; i++) {
            int f = toDigit(data[j], j) << 4;
            j++;
            f = f | toDigit(data[j], j);
            j++;
            out[i] = (byte)(f & 0xFF);
        }

        return out;
    }
}
/

ALTER JAVA SOURCE CUX_UNWRAPPER COMPILE
/

CREATE OR REPLACE PACKAGE CUX_UNWRAPPER IS
  FUNCTION UNWRAP(P_CLOB IN CLOB) RETURN CLOB;
END;
/

create or replace package body cux_unwrapper is

  --unzip
  function inflate(src in clob) return clob as
    language java name 'UNWRAPPER.Inflate( oracle.sql.CLOB ) return oracle.sql.CLOB';

  --Decrypt the main program
  function unwrap(p_clob  IN CLOB) return clob AS

    l_wrap varchar2(32767);

    l_inf       clob;
    l_res       clob;
    l_src       clob;
    l_inflate   varchar2(32767);
    l_temp      VARCHAR2(32767);
    l_bt        varchar2(32767);
    l_text      varchar2(32767);
    l_char      varchar2(2);
    l_len       number;
    l_slen      integer;
    l_offset    integer := 1;
    l_chunk_len integer := 10080;

    --Decryption byte comparison dictionary table
    l_dict varchar2(512) := '3D6585B318DBE287F152AB634BB5A05F' ||
                            '7D687B9B24C228678ADEA4261E03EB17' ||
                            '6F343E7A3FD2A96A0FE935561FB14D10' ||
                            '78D975F6BC4104816106F9ADD6D5297E' ||
                            '869E79E505BA84CC6E278EB05DA8F39F' ||
                            'D0A271B858DD2C38994C480755E4538C' ||
                            '46B62DA5AF322240DC50C3A1258B9C16' ||
                            '605CCFFD0C981CD4376D3C3A30E86C31' ||
                            '47F533DA43C8E35E1994ECE6A39514E0' ||
                            '9D64FA5915C52FCABB0BDFF297BF0A76' ||
                            'B449445A1DF0009621807F1A82394FC1' ||
                            'A7D70DD1D8FF139370EE5BEFBE09B977' ||
                            '72E7B254B72AC7739066200E51EDF87C' ||
                            '8F2EF412C62B83CDACCB3BC44EC06936' ||
                            '6202AE88FCAA4208A64557D39ABDE123' ||
                            '8D924A1189746B91FBFEC901EA1BF7CE';
    l_sl   varchar2(512) := '000102030405060708090A0B0C0D0E0F' ||
                            '101112131415161718191A1B1C1D1E1F' ||
                            '202122232425262728292A2B2C2D2E2F' ||
                            '303132333435363738393A3B3C3D3E3F' ||
                            '404142434445464748494A4B4C4D4E4F' ||
                            '505152535455565758595A5B5C5D5E5F' ||
                            '606162636465666768696A6B6C6D6E6F' ||
                            '707172737475767778797A7B7C7D7E7F' ||
                            '808182838485868788898A8B8C8D8E8F' ||
                            '909192939495969798999A9B9C9D9E9F' ||
                            'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF' ||
                            'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF' ||
                            'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF' ||
                            'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF' ||
                            'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF' ||
                            'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF';
  BEGIN
    dbms_lob.createtemporary(lob_loc => l_inf,
                             cache   => TRUE,
                             dur     => dbms_lob.session);
    --Get package ciphertext
    l_src := p_clob;

     --out_put('source:<'||l_src||'>');
    l_src := substr(l_src, regexp_instr(l_src, 'wrapped', 1, 1, 0, 'i'));
    l_src := rtrim(substr(l_src, instr(l_src, chr(10), 1, 20) + 1), chr(10));
    l_src := replace(l_src, chr(10), '');
    --dbms_output.put_line('source:<'||l_src||'>');
    --l_src:=substr(l_src,41);

    --base64 decoding
    l_len := dbms_lob.getlength(l_src);
    while l_offset < l_len loop
      if (l_len - l_offset) < 10080 then
        l_chunk_len := (l_len - l_offset);
      end if;
      l_temp := dbms_lob.substr(l_src, l_chunk_len, l_offset);
      l_bt   := utl_encode.base64_decode(utl_raw.cast_to_raw(l_temp));

      if l_bt is not null then
        if l_offset = 1 then
                     -- Remove the first 40 hash strings
          l_bt := substr(l_bt, 41);
        end if;
        -- l_wrap := l_wrap || l_bt;
                 -- dictionary table conversion
        l_bt := utl_raw.translate(l_bt, l_sl, l_dict);

        l_offset := l_offset + l_chunk_len;
        --    l_inflate := l_inflate || l_bt;
        dbms_lob.writeappend(l_inf, length(l_bt), l_bt);
      end if;

    end loop;

    /* dbms_output.put_line('base:' || l_wrap);
    dbms_output.put_line('<' || l_inflate || '>');*/

    --unzip
    l_res := inflate(l_inf);
    return l_res;
  END unwrap;
END;
/

set def &

---------------------------------------------
------------     SECTION END     ------------
------------ UNWRAP WRAPPED CODE ------------
---------------------------------------------

-- Create unwrapped table
create table DM_CODES_LOAD AS
select SYS.DBMS_CRYPTO.HASH(UNCODE,2) MD5_HASH,
       MD5_HASH MD5_HASH_WRAPPED,
       UNCODE CODE,
       'N' WRAPPED
from ( select cux_unwrapper.unwrap(code) uncode, MD5_HASH
       from DM_CODES
       where WRAPPED='Y');

-- Load back into DM_CODES
insert /*+ append */
  into DM_CODES (MD5_HASH, CODE, WRAPPED)
select MD5_HASH,
       CODE,
       'N' WRAPPED
from ( select MD5_HASH,
              CODE,
              RANK() over (partition by MD5_HASH order by rowid asc) col_ind
       from DM_CODES_LOAD
)
where col_ind=1;

commit;

-- Update DM_CODES
update DM_CODES T1 SET T1.MD5_HASH_UNWRAPPED =
       (SELECT T2.MD5_HASH
          FROM DM_CODES_LOAD T2
         WHERE T2.MD5_HASH_WRAPPED=T1.MD5_HASH)
WHERE  T1.WRAPPED = 'Y';

commit;

drop table DM_CODES_LOAD purge;

drop package cux_unwrapper;

drop java source CUX_UNWRAPPER;