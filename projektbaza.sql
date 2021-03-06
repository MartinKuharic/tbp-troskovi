PGDMP          $                z            postgres    14.1    14.1 q    w           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            x           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            y           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            z           1262    13754    postgres    DATABASE     g   CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Croatian_Croatia.1252';
    DROP DATABASE postgres;
                postgres    false            {           0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                   postgres    false    3450                        3079    16384 	   adminpack 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;
    DROP EXTENSION adminpack;
                   false            |           0    0    EXTENSION adminpack    COMMENT     M   COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';
                        false    2            ?            1255    16574    anzuriranje_info_poduzeca()    FUNCTION     f  CREATE FUNCTION public.anzuriranje_info_poduzeca() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_broj_radnika int;
begin
st_broj_radnika := (
  select broj_radnika 
  from poduzece
  where poduzece_id = new.poduzece_id
  );
  update poduzece 
  set broj_radnika = st_broj_radnika + 1
  where poduzece_id = new.poduzece_id;
  return new;
  end;$$;
 2   DROP FUNCTION public.anzuriranje_info_poduzeca();
       public          postgres    false            ?            1255    16576    anzuriranje_info_poduzeca2()    FUNCTION     e  CREATE FUNCTION public.anzuriranje_info_poduzeca2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_broj_radnika int;
begin
st_broj_radnika := (
  select broj_radnika
  from poduzece
  where poduzece_id = old.poduzece_id
  );
  update poduzece
  set broj_radnika = st_broj_radnika - 1
  where poduzece_id = old.poduzece_id;
  return new;
  end;$$;
 3   DROP FUNCTION public.anzuriranje_info_poduzeca2();
       public          postgres    false            ?            1255    16582     anzuriranje_info_radnog_mjesta()    FUNCTION     ?  CREATE FUNCTION public.anzuriranje_info_radnog_mjesta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_trenutno_broj_zaposlenih int;
begin
st_trenutno_broj_zaposlenih := (
  select trenutno_broj_zaposlenih
  from radno_mjesto
  where radno_mjesto_id = new.radno_mjesto_id
  );
  update radno_mjesto
  set trenutno_broj_zaposlenih = st_trenutno_broj_zaposlenih + 1
  where radno_mjesto_id = new.radno_mjesto_id;
  return new;
  end;$$;
 7   DROP FUNCTION public.anzuriranje_info_radnog_mjesta();
       public          postgres    false            ?            1255    16587 !   anzuriranje_info_radnog_mjesta2()    FUNCTION     ?  CREATE FUNCTION public.anzuriranje_info_radnog_mjesta2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_trenutno_broj_zaposlenih int;
begin
st_trenutno_broj_zaposlenih := (
  select trenutno_broj_zaposlenih
  from radno_mjesto
  where radno_mjesto_id = old.radno_mjesto_id
  );
  update radno_mjesto
  set trenutno_broj_zaposlenih = st_trenutno_broj_zaposlenih - 1
  where radno_mjesto_id = old.radno_mjesto_id;
  return new;
  end;$$;
 8   DROP FUNCTION public.anzuriranje_info_radnog_mjesta2();
       public          postgres    false            ?            1255    16609    isplati(integer, integer)    FUNCTION     ?  CREATE FUNCTION public.isplati(par_radnik integer, par_mjesec integer) RETURNS void
    LANGUAGE plpgsql
    AS $$declare no_radno_mjesto int;
declare placa int;
declare bonus int;
declare no_iznos int;
declare postoji bool;
begin
no_radno_mjesto := (
  select radno_mjesto_id 
  from radnik
  where radnik_id = par_radnik
  );
placa := ( 
  select pripadajuca_placa 
  from radno_mjesto
  where radno_mjesto_id = no_radno_mjesto
  );
bonus := (
  select bonus_djeca
  from bonusi
  where radnik_id = par_radnik
  );
no_iznos := (
  placa + bonus
  );
postoji := exists (
  select isplata 
  from isplata
  where radnik_id = par_radnik and mjesec = par_mjesec
  );
if not postoji then 
  insert into isplata (iznos, mjesec, radnik_id, radno_mjesto_id)
  values (no_iznos, par_mjesec, par_radnik, no_radno_mjesto);
  else 
  raise exception 'Vec postoji isplata za zadanog radnika u tom mjesecu.
  Pokusajte ju potraziti.';
  end if;
end;
$$;
 F   DROP FUNCTION public.isplati(par_radnik integer, par_mjesec integer);
       public          postgres    false            ?            1255    16611    obracunaj(integer, integer)    FUNCTION       CREATE FUNCTION public.obracunaj(par_radnik integer, par_mjesec integer) RETURNS void
    LANGUAGE plpgsql
    AS $$declare no_neto int;
declare no_bruto int;
declare no_davanja int;
declare no_bonus int;
declare no_isplata_id int;
declare no_davanja_id int;
declare postoji bool;
begin
no_davanja := (
  select iznos 
  from davanja
  where radnik_id = par_radnik and aktivno = true
  );
no_neto := (
  select iznos 
  from isplata
  where radnik_id = par_radnik and mjesec = par_mjesec
  );
no_bruto := (
  no_neto + no_davanja
  );
no_bonus := (
  select bonus_djeca 
  from bonusi
  where radnik_id = par_radnik
  );
no_isplata_id := (
  select isplata_id 
  from isplata
  where radnik_id = par_radnik and mjesec = par_mjesec
  );
no_davanja_id := (
  select davanja_id 
  from davanja
  where radnik_id = par_radnik and aktivno = true
  );
postoji := exists (
  select obracun
  from obracun
  where radnik_id = par_radnik and mjesec = par_mjesec
  );
if not postoji then 
  insert into obracun (neto, bruto, bonusi, davanja, mjesec, radnik_id, isplata_id, davanja_id)
  values (no_neto, no_bruto, no_bonus, no_davanja, par_mjesec, par_radnik, no_isplata_id, no_davanja_id);
  else
  raise exception 'Placa za trazenog radnika u navedenom mjestu je vec obracunata.';
  end if;
end;
  $$;
 H   DROP FUNCTION public.obracunaj(par_radnik integer, par_mjesec integer);
       public          postgres    false            ?            1255    16601    popuni_bonuse()    FUNCTION     
  CREATE FUNCTION public.popuni_bonuse() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare no_iznos int;
declare no_izracun_id int;
begin
no_iznos := (
  select iznos 
  from izracun_bonusa_djeca
  where broj_djece = new.broj_djece and aktivno = true
  );
no_izracun_id := (
  select izracun_djeca_id
  from izracun_bonusa_djeca
  where broj_djece = new.broj_djece and aktivno = true
  );
insert into bonusi (bonus_djeca, radnik_id, izracun_djeca_id)
values (no_iznos, new.radnik_id, no_izracun_id);
return new;
end;$$;
 &   DROP FUNCTION public.popuni_bonuse();
       public          postgres    false            ?            1255    16618    popuni_godisnji()    FUNCTION     B  CREATE FUNCTION public.popuni_godisnji() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare no_broj_dana int;
declare no_izracun_odmora_id int;
begin
no_broj_dana := (
  select dani_odmora 
  from izracun_godisnjeg_odmora
  where radni_staz = new.radni_staz and aktivno = true
  );
no_izracun_odmora_id := (
  select izracun_odmor_id 
  from izracun_godisnjeg_odmora
  where radni_staz = new.radni_staz and aktivno = true
  );
insert into godisni_odmor (broj_dana, radnik_id, izracun_odmora_id)
values (no_broj_dana, new.radnik_id, no_izracun_odmora_id);
return new;
end;$$;
 (   DROP FUNCTION public.popuni_godisnji();
       public          postgres    false            ?            1255    16595    promjena_iznosa_davanja()    FUNCTION     ?  CREATE FUNCTION public.promjena_iznosa_davanja() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_zapis davanja;
begin
st_zapis := (
  select davanja
  from davanja
  where radnik_id = new.radnik_id and aktivno = true
  );
update davanja
set vrijedi_do = now()
where radnik_id = new.radnik_id and aktivno = true;
update davanja
set aktivno = false 
where radnik_id = new.radnik_id and aktivno = true;
return new;
end;$$;
 0   DROP FUNCTION public.promjena_iznosa_davanja();
       public          postgres    false            ?            1255    16592     promjena_izracuna_bonusa_djeca()    FUNCTION     ?  CREATE FUNCTION public.promjena_izracuna_bonusa_djeca() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_zapis izracun_bonusa_djeca;
begin
st_zapis := (
  select izracun_bonusa_djeca
  from izracun_bonusa_djeca
  where broj_djece = new.broj_djece and aktivno = true
  );
update izracun_bonusa_djeca 
set vrijedi_do = now()
where broj_djece = new.broj_djece and aktivno = true;
update izracun_bonusa_djeca 
set aktivno = false
where broj_djece = new.broj_djece and aktivno = true;
return new;
end;
$$;
 7   DROP FUNCTION public.promjena_izracuna_bonusa_djeca();
       public          postgres    false            ?            1255    16616 $   promjena_izracuna_godisnjeg_odmora()    FUNCTION     ?  CREATE FUNCTION public.promjena_izracuna_godisnjeg_odmora() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare st_zapis izracun_godisnjeg_odmora;
begin
st_zapis := (
  select izracun_godisnjeg_odmora
  from izracun_godisnjeg_odmora
  where radni_staz = new.radni_staz and aktivno = true
  );
  update izracun_godisnjeg_odmora
  set aktivno = false 
  where radni_staz = new.radni_staz and aktivno = true;
  return new;
end;$$;
 ;   DROP FUNCTION public.promjena_izracuna_godisnjeg_odmora();
       public          postgres    false            ?            1255    16590 '   provjera_mogucnosti_dodavanja_radnika()    FUNCTION     *  CREATE FUNCTION public.provjera_mogucnosti_dodavanja_radnika() RETURNS trigger
    LANGUAGE plpgsql
    AS $$declare trenutno int;
declare maximalno int;
declare dopusti bool;
begin
trenutno := (
  select trenutno_broj_zaposlenih
  from radno_mjesto
  where radno_mjesto_id = new.radno_mjesto_id
  );
maximalno := (
  select max_broj_zaposlenih
  from radno_mjesto
  where radno_mjesto_id = new.radno_mjesto_id
  );
if trenutno < maximalno then
  return new;
  else 
    raise exception 'Radno mjesto je popunjeno.';
    return old;
  end if;
end;
  $$;
 >   DROP FUNCTION public.provjera_mogucnosti_dodavanja_radnika();
       public          postgres    false            ?            1259    16499    bonusi    TABLE     ?   CREATE TABLE public.bonusi (
    bonusi_id integer NOT NULL,
    bonus_djeca integer,
    radnik_id integer,
    izracun_djeca_id integer
);
    DROP TABLE public.bonusi;
       public         heap    postgres    false            ?            1259    16498    bonusi_bonusi_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.bonusi_bonusi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.bonusi_bonusi_id_seq;
       public          postgres    false    224            }           0    0    bonusi_bonusi_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.bonusi_bonusi_id_seq OWNED BY public.bonusi.bonusi_id;
          public          postgres    false    223            ?            1259    16533    davanja    TABLE     ?   CREATE TABLE public.davanja (
    davanja_id integer NOT NULL,
    iznos integer,
    vrijedi_od timestamp without time zone DEFAULT now(),
    vrijedi_do timestamp without time zone,
    aktivno boolean DEFAULT true,
    radnik_id integer
);
    DROP TABLE public.davanja;
       public         heap    postgres    false            ?            1259    16532    davanja_davanja_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.davanja_davanja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.davanja_davanja_id_seq;
       public          postgres    false    228            ~           0    0    davanja_davanja_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.davanja_davanja_id_seq OWNED BY public.davanja.davanja_id;
          public          postgres    false    227            ?            1259    16482    godisni_odmor    TABLE     ?   CREATE TABLE public.godisni_odmor (
    godisni_id integer NOT NULL,
    broj_dana integer,
    radnik_id integer,
    izracun_odmora_id integer
);
 !   DROP TABLE public.godisni_odmor;
       public         heap    postgres    false            ?            1259    16481    godisni_odmor_godisni_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.godisni_odmor_godisni_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.godisni_odmor_godisni_id_seq;
       public          postgres    false    222                       0    0    godisni_odmor_godisni_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.godisni_odmor_godisni_id_seq OWNED BY public.godisni_odmor.godisni_id;
          public          postgres    false    221            ?            1259    16516    isplata    TABLE     ?   CREATE TABLE public.isplata (
    isplata_id integer NOT NULL,
    iznos integer,
    mjesec integer,
    radnik_id integer,
    radno_mjesto_id integer
);
    DROP TABLE public.isplata;
       public         heap    postgres    false            ?            1259    16515    isplata_isplata_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.isplata_isplata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.isplata_isplata_id_seq;
       public          postgres    false    226            ?           0    0    isplata_isplata_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.isplata_isplata_id_seq OWNED BY public.isplata.isplata_id;
          public          postgres    false    225            ?            1259    16440    izracun_godisnjeg_odmora    TABLE     ?   CREATE TABLE public.izracun_godisnjeg_odmora (
    izracun_odmor_id integer NOT NULL,
    radni_staz integer,
    dani_odmora integer,
    aktivno boolean DEFAULT true
);
 ,   DROP TABLE public.izracun_godisnjeg_odmora;
       public         heap    postgres    false            ?            1259    16439 *   izracunGodisnjegOdmora_izracun_odmorID_seq    SEQUENCE     ?   CREATE SEQUENCE public."izracunGodisnjegOdmora_izracun_odmorID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE public."izracunGodisnjegOdmora_izracun_odmorID_seq";
       public          postgres    false    214            ?           0    0 *   izracunGodisnjegOdmora_izracun_odmorID_seq    SEQUENCE OWNED BY     ~   ALTER SEQUENCE public."izracunGodisnjegOdmora_izracun_odmorID_seq" OWNED BY public.izracun_godisnjeg_odmora.izracun_odmor_id;
          public          postgres    false    213            ?            1259    16447    izracun_bonusa_djeca    TABLE       CREATE TABLE public.izracun_bonusa_djeca (
    izracun_djeca_id integer NOT NULL,
    broj_djece integer,
    iznos integer,
    vrijedi_od timestamp without time zone DEFAULT now(),
    vrijedi_do timestamp without time zone,
    aktivno boolean DEFAULT true
);
 (   DROP TABLE public.izracun_bonusa_djeca;
       public         heap    postgres    false            ?            1259    16446 )   izracun_bonusa_djeca_izracun_djeca_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.izracun_bonusa_djeca_izracun_djeca_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 @   DROP SEQUENCE public.izracun_bonusa_djeca_izracun_djeca_id_seq;
       public          postgres    false    216            ?           0    0 )   izracun_bonusa_djeca_izracun_djeca_id_seq    SEQUENCE OWNED BY     w   ALTER SEQUENCE public.izracun_bonusa_djeca_izracun_djeca_id_seq OWNED BY public.izracun_bonusa_djeca.izracun_djeca_id;
          public          postgres    false    215            ?            1259    16546    obracun    TABLE     ?   CREATE TABLE public.obracun (
    obracun_id integer NOT NULL,
    neto integer,
    bruto integer,
    bonusi integer,
    davanja integer,
    mjesec integer,
    radnik_id integer,
    isplata_id integer,
    davanja_id integer
);
    DROP TABLE public.obracun;
       public         heap    postgres    false            ?            1259    16545    obracun_obracun_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.obracun_obracun_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.obracun_obracun_id_seq;
       public          postgres    false    230            ?           0    0    obracun_obracun_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.obracun_obracun_id_seq OWNED BY public.obracun.obracun_id;
          public          postgres    false    229            ?            1259    16433    poduzece    TABLE     ?   CREATE TABLE public.poduzece (
    poduzece_id integer NOT NULL,
    naziv character varying(15),
    sjediste character varying(15),
    broj_radnika integer
);
    DROP TABLE public.poduzece;
       public         heap    postgres    false            ?            1259    16432    poduzece_poduzeceID_seq    SEQUENCE     ?   CREATE SEQUENCE public."poduzece_poduzeceID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."poduzece_poduzeceID_seq";
       public          postgres    false    212            ?           0    0    poduzece_poduzeceID_seq    SEQUENCE OWNED BY     V   ALTER SEQUENCE public."poduzece_poduzeceID_seq" OWNED BY public.poduzece.poduzece_id;
          public          postgres    false    211            ?            1259    16397    probnatablica    TABLE     '   CREATE TABLE public.probnatablica (
);
 !   DROP TABLE public.probnatablica;
       public         heap    postgres    false            ?            1259    16465    radnik    TABLE     @  CREATE TABLE public.radnik (
    radnik_id integer NOT NULL,
    ime character varying(15),
    prezime character varying(15),
    radni_staz integer,
    broj_djece integer,
    pocetak_rada timestamp without time zone,
    kraj_rada timestamp without time zone,
    poduzece_id integer,
    radno_mjesto_id integer
);
    DROP TABLE public.radnik;
       public         heap    postgres    false            ?            1259    16464    radnik_radnik_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.radnik_radnik_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.radnik_radnik_id_seq;
       public          postgres    false    220            ?           0    0    radnik_radnik_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.radnik_radnik_id_seq OWNED BY public.radnik.radnik_id;
          public          postgres    false    219            ?            1259    16456    radno_mjesto    TABLE     h  CREATE TABLE public.radno_mjesto (
    radno_mjesto_id integer NOT NULL,
    naziv_radnog_mjesta character varying(15),
    pripadajuca_placa integer,
    trenutno_broj_zaposlenih integer,
    max_broj_zaposlenih integer,
    vrijedi_od timestamp without time zone DEFAULT now(),
    vrijedi_do timestamp without time zone,
    aktivno boolean DEFAULT true
);
     DROP TABLE public.radno_mjesto;
       public         heap    postgres    false            ?            1259    16455     radno_mjesto_radno_mjesto_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.radno_mjesto_radno_mjesto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.radno_mjesto_radno_mjesto_id_seq;
       public          postgres    false    218            ?           0    0     radno_mjesto_radno_mjesto_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.radno_mjesto_radno_mjesto_id_seq OWNED BY public.radno_mjesto.radno_mjesto_id;
          public          postgres    false    217            ?           2604    16502    bonusi bonusi_id    DEFAULT     t   ALTER TABLE ONLY public.bonusi ALTER COLUMN bonusi_id SET DEFAULT nextval('public.bonusi_bonusi_id_seq'::regclass);
 ?   ALTER TABLE public.bonusi ALTER COLUMN bonusi_id DROP DEFAULT;
       public          postgres    false    223    224    224            ?           2604    16536    davanja davanja_id    DEFAULT     x   ALTER TABLE ONLY public.davanja ALTER COLUMN davanja_id SET DEFAULT nextval('public.davanja_davanja_id_seq'::regclass);
 A   ALTER TABLE public.davanja ALTER COLUMN davanja_id DROP DEFAULT;
       public          postgres    false    228    227    228            ?           2604    16485    godisni_odmor godisni_id    DEFAULT     ?   ALTER TABLE ONLY public.godisni_odmor ALTER COLUMN godisni_id SET DEFAULT nextval('public.godisni_odmor_godisni_id_seq'::regclass);
 G   ALTER TABLE public.godisni_odmor ALTER COLUMN godisni_id DROP DEFAULT;
       public          postgres    false    222    221    222            ?           2604    16519    isplata isplata_id    DEFAULT     x   ALTER TABLE ONLY public.isplata ALTER COLUMN isplata_id SET DEFAULT nextval('public.isplata_isplata_id_seq'::regclass);
 A   ALTER TABLE public.isplata ALTER COLUMN isplata_id DROP DEFAULT;
       public          postgres    false    226    225    226            ?           2604    16450 %   izracun_bonusa_djeca izracun_djeca_id    DEFAULT     ?   ALTER TABLE ONLY public.izracun_bonusa_djeca ALTER COLUMN izracun_djeca_id SET DEFAULT nextval('public.izracun_bonusa_djeca_izracun_djeca_id_seq'::regclass);
 T   ALTER TABLE public.izracun_bonusa_djeca ALTER COLUMN izracun_djeca_id DROP DEFAULT;
       public          postgres    false    215    216    216            ?           2604    16443 )   izracun_godisnjeg_odmora izracun_odmor_id    DEFAULT     ?   ALTER TABLE ONLY public.izracun_godisnjeg_odmora ALTER COLUMN izracun_odmor_id SET DEFAULT nextval('public."izracunGodisnjegOdmora_izracun_odmorID_seq"'::regclass);
 X   ALTER TABLE public.izracun_godisnjeg_odmora ALTER COLUMN izracun_odmor_id DROP DEFAULT;
       public          postgres    false    214    213    214            ?           2604    16549    obracun obracun_id    DEFAULT     x   ALTER TABLE ONLY public.obracun ALTER COLUMN obracun_id SET DEFAULT nextval('public.obracun_obracun_id_seq'::regclass);
 A   ALTER TABLE public.obracun ALTER COLUMN obracun_id DROP DEFAULT;
       public          postgres    false    230    229    230            ?           2604    16436    poduzece poduzece_id    DEFAULT     }   ALTER TABLE ONLY public.poduzece ALTER COLUMN poduzece_id SET DEFAULT nextval('public."poduzece_poduzeceID_seq"'::regclass);
 C   ALTER TABLE public.poduzece ALTER COLUMN poduzece_id DROP DEFAULT;
       public          postgres    false    212    211    212            ?           2604    16468    radnik radnik_id    DEFAULT     t   ALTER TABLE ONLY public.radnik ALTER COLUMN radnik_id SET DEFAULT nextval('public.radnik_radnik_id_seq'::regclass);
 ?   ALTER TABLE public.radnik ALTER COLUMN radnik_id DROP DEFAULT;
       public          postgres    false    220    219    220            ?           2604    16459    radno_mjesto radno_mjesto_id    DEFAULT     ?   ALTER TABLE ONLY public.radno_mjesto ALTER COLUMN radno_mjesto_id SET DEFAULT nextval('public.radno_mjesto_radno_mjesto_id_seq'::regclass);
 K   ALTER TABLE public.radno_mjesto ALTER COLUMN radno_mjesto_id DROP DEFAULT;
       public          postgres    false    217    218    218            n          0    16499    bonusi 
   TABLE DATA           U   COPY public.bonusi (bonusi_id, bonus_djeca, radnik_id, izracun_djeca_id) FROM stdin;
    public          postgres    false    224   ɥ       r          0    16533    davanja 
   TABLE DATA           `   COPY public.davanja (davanja_id, iznos, vrijedi_od, vrijedi_do, aktivno, radnik_id) FROM stdin;
    public          postgres    false    228   ??       l          0    16482    godisni_odmor 
   TABLE DATA           \   COPY public.godisni_odmor (godisni_id, broj_dana, radnik_id, izracun_odmora_id) FROM stdin;
    public          postgres    false    222   d?       p          0    16516    isplata 
   TABLE DATA           X   COPY public.isplata (isplata_id, iznos, mjesec, radnik_id, radno_mjesto_id) FROM stdin;
    public          postgres    false    226   ??       f          0    16447    izracun_bonusa_djeca 
   TABLE DATA           t   COPY public.izracun_bonusa_djeca (izracun_djeca_id, broj_djece, iznos, vrijedi_od, vrijedi_do, aktivno) FROM stdin;
    public          postgres    false    216   ??       d          0    16440    izracun_godisnjeg_odmora 
   TABLE DATA           f   COPY public.izracun_godisnjeg_odmora (izracun_odmor_id, radni_staz, dani_odmora, aktivno) FROM stdin;
    public          postgres    false    214   ;?       t          0    16546    obracun 
   TABLE DATA           v   COPY public.obracun (obracun_id, neto, bruto, bonusi, davanja, mjesec, radnik_id, isplata_id, davanja_id) FROM stdin;
    public          postgres    false    230   o?       b          0    16433    poduzece 
   TABLE DATA           N   COPY public.poduzece (poduzece_id, naziv, sjediste, broj_radnika) FROM stdin;
    public          postgres    false    212   ??       `          0    16397    probnatablica 
   TABLE DATA           '   COPY public.probnatablica  FROM stdin;
    public          postgres    false    210   ??       j          0    16465    radnik 
   TABLE DATA           ?   COPY public.radnik (radnik_id, ime, prezime, radni_staz, broj_djece, pocetak_rada, kraj_rada, poduzece_id, radno_mjesto_id) FROM stdin;
    public          postgres    false    220   ?       h          0    16456    radno_mjesto 
   TABLE DATA           ?   COPY public.radno_mjesto (radno_mjesto_id, naziv_radnog_mjesta, pripadajuca_placa, trenutno_broj_zaposlenih, max_broj_zaposlenih, vrijedi_od, vrijedi_do, aktivno) FROM stdin;
    public          postgres    false    218   ??       ?           0    0    bonusi_bonusi_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.bonusi_bonusi_id_seq', 5, true);
          public          postgres    false    223            ?           0    0    davanja_davanja_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.davanja_davanja_id_seq', 6, true);
          public          postgres    false    227            ?           0    0    godisni_odmor_godisni_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.godisni_odmor_godisni_id_seq', 2, true);
          public          postgres    false    221            ?           0    0    isplata_isplata_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.isplata_isplata_id_seq', 7, true);
          public          postgres    false    225            ?           0    0 *   izracunGodisnjegOdmora_izracun_odmorID_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public."izracunGodisnjegOdmora_izracun_odmorID_seq"', 5, true);
          public          postgres    false    213            ?           0    0 )   izracun_bonusa_djeca_izracun_djeca_id_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.izracun_bonusa_djeca_izracun_djeca_id_seq', 8, true);
          public          postgres    false    215            ?           0    0    obracun_obracun_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.obracun_obracun_id_seq', 360, true);
          public          postgres    false    229            ?           0    0    poduzece_poduzeceID_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."poduzece_poduzeceID_seq"', 1, true);
          public          postgres    false    211            ?           0    0    radnik_radnik_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.radnik_radnik_id_seq', 10, true);
          public          postgres    false    219            ?           0    0     radno_mjesto_radno_mjesto_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.radno_mjesto_radno_mjesto_id_seq', 1, true);
          public          postgres    false    217            ?           2606    16504    bonusi bonusi_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.bonusi
    ADD CONSTRAINT bonusi_pkey PRIMARY KEY (bonusi_id);
 <   ALTER TABLE ONLY public.bonusi DROP CONSTRAINT bonusi_pkey;
       public            postgres    false    224            ?           2606    16538    davanja davanja_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.davanja
    ADD CONSTRAINT davanja_pkey PRIMARY KEY (davanja_id);
 >   ALTER TABLE ONLY public.davanja DROP CONSTRAINT davanja_pkey;
       public            postgres    false    228            ?           2606    16487     godisni_odmor godisni_odmor_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.godisni_odmor
    ADD CONSTRAINT godisni_odmor_pkey PRIMARY KEY (godisni_id);
 J   ALTER TABLE ONLY public.godisni_odmor DROP CONSTRAINT godisni_odmor_pkey;
       public            postgres    false    222            ?           2606    16521    isplata isplata_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.isplata
    ADD CONSTRAINT isplata_pkey PRIMARY KEY (isplata_id);
 >   ALTER TABLE ONLY public.isplata DROP CONSTRAINT isplata_pkey;
       public            postgres    false    226            ?           2606    16445 4   izracun_godisnjeg_odmora izracunGodisnjegOdmora_pkey 
   CONSTRAINT     ?   ALTER TABLE ONLY public.izracun_godisnjeg_odmora
    ADD CONSTRAINT "izracunGodisnjegOdmora_pkey" PRIMARY KEY (izracun_odmor_id);
 `   ALTER TABLE ONLY public.izracun_godisnjeg_odmora DROP CONSTRAINT "izracunGodisnjegOdmora_pkey";
       public            postgres    false    214            ?           2606    16454 .   izracun_bonusa_djeca izracun_bonusa_djeca_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.izracun_bonusa_djeca
    ADD CONSTRAINT izracun_bonusa_djeca_pkey PRIMARY KEY (izracun_djeca_id);
 X   ALTER TABLE ONLY public.izracun_bonusa_djeca DROP CONSTRAINT izracun_bonusa_djeca_pkey;
       public            postgres    false    216            ?           2606    16551    obracun obracun_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.obracun
    ADD CONSTRAINT obracun_pkey PRIMARY KEY (obracun_id);
 >   ALTER TABLE ONLY public.obracun DROP CONSTRAINT obracun_pkey;
       public            postgres    false    230            ?           2606    16438    poduzece poduzece_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.poduzece
    ADD CONSTRAINT poduzece_pkey PRIMARY KEY (poduzece_id);
 @   ALTER TABLE ONLY public.poduzece DROP CONSTRAINT poduzece_pkey;
       public            postgres    false    212            ?           2606    16470    radnik radnik_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.radnik
    ADD CONSTRAINT radnik_pkey PRIMARY KEY (radnik_id);
 <   ALTER TABLE ONLY public.radnik DROP CONSTRAINT radnik_pkey;
       public            postgres    false    220            ?           2606    16463    radno_mjesto radno_mjesto_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.radno_mjesto
    ADD CONSTRAINT radno_mjesto_pkey PRIMARY KEY (radno_mjesto_id);
 H   ALTER TABLE ONLY public.radno_mjesto DROP CONSTRAINT radno_mjesto_pkey;
       public            postgres    false    218            ?           2620    16577    radnik brisanje_radnika    TRIGGER     ?   CREATE TRIGGER brisanje_radnika AFTER DELETE ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.anzuriranje_info_poduzeca2();
 0   DROP TRIGGER brisanje_radnika ON public.radnik;
       public          postgres    false    220    232            ?           2620    16588 !   radnik brisanje_radnika_rd_mjesto    TRIGGER     ?   CREATE TRIGGER brisanje_radnika_rd_mjesto AFTER DELETE ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.anzuriranje_info_radnog_mjesta2();
 :   DROP TRIGGER brisanje_radnika_rd_mjesto ON public.radnik;
       public          postgres    false    245    220            ?           2620    16602    radnik dodaj_bonuse    TRIGGER     p   CREATE TRIGGER dodaj_bonuse AFTER INSERT ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.popuni_bonuse();
 ,   DROP TRIGGER dodaj_bonuse ON public.radnik;
       public          postgres    false    220    249            ?           2620    16619    radnik dodaj_godisnji    TRIGGER     t   CREATE TRIGGER dodaj_godisnji AFTER INSERT ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.popuni_godisnji();
 .   DROP TRIGGER dodaj_godisnji ON public.radnik;
       public          postgres    false    253    220            ?           2620    16599 %   davanja dodavanje_obnovljenog_davanja    TRIGGER     ?   CREATE TRIGGER dodavanje_obnovljenog_davanja BEFORE INSERT ON public.davanja FOR EACH ROW EXECUTE FUNCTION public.promjena_iznosa_davanja();
 >   DROP TRIGGER dodavanje_obnovljenog_davanja ON public.davanja;
       public          postgres    false    248    228            ?           2620    16594 1   izracun_bonusa_djeca dodavanje_obnovljenog_zapisa    TRIGGER     ?   CREATE TRIGGER dodavanje_obnovljenog_zapisa BEFORE INSERT ON public.izracun_bonusa_djeca FOR EACH ROW EXECUTE FUNCTION public.promjena_izracuna_bonusa_djeca();
 J   DROP TRIGGER dodavanje_obnovljenog_zapisa ON public.izracun_bonusa_djeca;
       public          postgres    false    216    247            ?           2620    16617 >   izracun_godisnjeg_odmora dodavanje_obnovljenog_zapisa_godisnji    TRIGGER     ?   CREATE TRIGGER dodavanje_obnovljenog_zapisa_godisnji BEFORE INSERT ON public.izracun_godisnjeg_odmora FOR EACH ROW EXECUTE FUNCTION public.promjena_izracuna_godisnjeg_odmora();
 W   DROP TRIGGER dodavanje_obnovljenog_zapisa_godisnji ON public.izracun_godisnjeg_odmora;
       public          postgres    false    252    214            ?           2620    16575    radnik dodavanje_radnika    TRIGGER     ?   CREATE TRIGGER dodavanje_radnika AFTER INSERT ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.anzuriranje_info_poduzeca();
 1   DROP TRIGGER dodavanje_radnika ON public.radnik;
       public          postgres    false    231    220            ?           2620    16583 "   radnik dodavanje_radnika_rd_mjesto    TRIGGER     ?   CREATE TRIGGER dodavanje_radnika_rd_mjesto AFTER INSERT ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.anzuriranje_info_radnog_mjesta();
 ;   DROP TRIGGER dodavanje_radnika_rd_mjesto ON public.radnik;
       public          postgres    false    242    220            ?           2620    16591 "   radnik mogucnost_dodavanja_radnika    TRIGGER     ?   CREATE TRIGGER mogucnost_dodavanja_radnika BEFORE INSERT ON public.radnik FOR EACH ROW EXECUTE FUNCTION public.provjera_mogucnosti_dodavanja_radnika();
 ;   DROP TRIGGER mogucnost_dodavanja_radnika ON public.radnik;
       public          postgres    false    246    220            ?           2606    16510 3   bonusi bonusi_izracun_djaca_id_izracun_bonusa_djeca    FK CONSTRAINT     ?   ALTER TABLE ONLY public.bonusi
    ADD CONSTRAINT bonusi_izracun_djaca_id_izracun_bonusa_djeca FOREIGN KEY (izracun_djeca_id) REFERENCES public.izracun_bonusa_djeca(izracun_djeca_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ]   ALTER TABLE ONLY public.bonusi DROP CONSTRAINT bonusi_izracun_djaca_id_izracun_bonusa_djeca;
       public          postgres    false    3248    216    224            ?           2606    16505    bonusi bonusi_radnik_id_radnik    FK CONSTRAINT     ?   ALTER TABLE ONLY public.bonusi
    ADD CONSTRAINT bonusi_radnik_id_radnik FOREIGN KEY (radnik_id) REFERENCES public.radnik(radnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 H   ALTER TABLE ONLY public.bonusi DROP CONSTRAINT bonusi_radnik_id_radnik;
       public          postgres    false    224    220    3252            ?           2606    16539     davanja davanja_radnik_id_radnik    FK CONSTRAINT     ?   ALTER TABLE ONLY public.davanja
    ADD CONSTRAINT davanja_radnik_id_radnik FOREIGN KEY (radnik_id) REFERENCES public.radnik(radnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 J   ALTER TABLE ONLY public.davanja DROP CONSTRAINT davanja_radnik_id_radnik;
       public          postgres    false    228    220    3252            ?           2606    16488 /   godisni_odmor godisni_odmor_radnik_id_radnik_id    FK CONSTRAINT     ?   ALTER TABLE ONLY public.godisni_odmor
    ADD CONSTRAINT godisni_odmor_radnik_id_radnik_id FOREIGN KEY (radnik_id) REFERENCES public.radnik(radnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.godisni_odmor DROP CONSTRAINT godisni_odmor_radnik_id_radnik_id;
       public          postgres    false    222    220    3252            ?           2606    16493 G   godisni_odmor godisnji_odmor_izracun_odmora_id_izracun_godisnjeg_odmora    FK CONSTRAINT     ?   ALTER TABLE ONLY public.godisni_odmor
    ADD CONSTRAINT godisnji_odmor_izracun_odmora_id_izracun_godisnjeg_odmora FOREIGN KEY (izracun_odmora_id) REFERENCES public.izracun_godisnjeg_odmora(izracun_odmor_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 q   ALTER TABLE ONLY public.godisni_odmor DROP CONSTRAINT godisnji_odmor_izracun_odmora_id_izracun_godisnjeg_odmora;
       public          postgres    false    214    222    3246            ?           2606    16522     isplata isplata_radnik:id_radnik    FK CONSTRAINT     ?   ALTER TABLE ONLY public.isplata
    ADD CONSTRAINT "isplata_radnik:id_radnik" FOREIGN KEY (radnik_id) REFERENCES public.radnik(radnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.isplata DROP CONSTRAINT "isplata_radnik:id_radnik";
       public          postgres    false    226    3252    220            ?           2606    16527 ,   isplata isplata_radno_mjesto_id_radno_mjesto    FK CONSTRAINT     ?   ALTER TABLE ONLY public.isplata
    ADD CONSTRAINT isplata_radno_mjesto_id_radno_mjesto FOREIGN KEY (radno_mjesto_id) REFERENCES public.radno_mjesto(radno_mjesto_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.isplata DROP CONSTRAINT isplata_radno_mjesto_id_radno_mjesto;
       public          postgres    false    218    3250    226            ?           2606    16567 "   obracun obracun_davanja_id_davanja    FK CONSTRAINT     ?   ALTER TABLE ONLY public.obracun
    ADD CONSTRAINT obracun_davanja_id_davanja FOREIGN KEY (davanja_id) REFERENCES public.davanja(davanja_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.obracun DROP CONSTRAINT obracun_davanja_id_davanja;
       public          postgres    false    228    3260    230            ?           2606    16557 "   obracun obracun_isplata_id_isplata    FK CONSTRAINT     ?   ALTER TABLE ONLY public.obracun
    ADD CONSTRAINT obracun_isplata_id_isplata FOREIGN KEY (isplata_id) REFERENCES public.isplata(isplata_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.obracun DROP CONSTRAINT obracun_isplata_id_isplata;
       public          postgres    false    226    230    3258            ?           2606    16552     obracun obracun_radnik_id_radnik    FK CONSTRAINT     ?   ALTER TABLE ONLY public.obracun
    ADD CONSTRAINT obracun_radnik_id_radnik FOREIGN KEY (radnik_id) REFERENCES public.radnik(radnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 J   ALTER TABLE ONLY public.obracun DROP CONSTRAINT obracun_radnik_id_radnik;
       public          postgres    false    220    3252    230            ?           2606    16471 "   radnik radnik_poduzece_id_poduzece    FK CONSTRAINT     ?   ALTER TABLE ONLY public.radnik
    ADD CONSTRAINT radnik_poduzece_id_poduzece FOREIGN KEY (poduzece_id) REFERENCES public.poduzece(poduzece_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.radnik DROP CONSTRAINT radnik_poduzece_id_poduzece;
       public          postgres    false    220    212    3244            ?           2606    16476 *   radnik radnik_radno_mjesto_id_radno_mjesto    FK CONSTRAINT     ?   ALTER TABLE ONLY public.radnik
    ADD CONSTRAINT radnik_radno_mjesto_id_radno_mjesto FOREIGN KEY (radno_mjesto_id) REFERENCES public.radno_mjesto(radno_mjesto_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.radnik DROP CONSTRAINT radnik_radno_mjesto_id_radno_mjesto;
       public          postgres    false    3250    218    220            n   #   x?3?447?4?4?2?,?,S0?? Ȍ???? ]??      r   X   x?m˻?0 ?ڞ?b???????BP?;?`PVm,M??R??N??ݿəzd???g?????
?b?eQ,??C?f????v?      l      x?3?420???4?2???=... 0?{      p      x?3?4437?44?4?4?????? ??      f   o   x?}λ?0?᚜??8RIqO?:d?B???????)))@??[n?eV2a??en@?^#?{(?n?+????Qmȴ???X}????<??׍?|:-x?J6GOw
3?  ?&?      d   $   x?3?4?420?,?2?4?8ӸL?C?P? ZB      t   0   x?3?4437????4?RF????@?D???? ,ib ?4?????? 3?	o      b   :   x?3???LN?VH??Bΰ??????dNs.CN?Ԫ?l=??O~R~??!W? ???      `      x?????? ? ?      j   ?   x?}????0E??W?X3?G&?@??h?V4??	!Y????L?]("Yrq}?g.?eh??????^oz? #?i?2?=G*M?J?????yl?S?~HyT?'???h?`?J??Q?`?r?æ]?`??h+?????hty?HY??^/Cݩ???j???Bޔ(?*?o???Y??+u?A?y?th??d;??!,?????ZG:?????q~??)?? T?      h   @   x?3?,(?O/J?M-?4450?4B###]C]#C3+cS+#=C#3#s????=... ??\     