PGDMP  '                 	    |            DBbiblioteca    16.4    16.4 �    t           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            u           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            v           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            w           1262    25401    DBbiblioteca    DATABASE     �   CREATE DATABASE "DBbiblioteca" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252';
    DROP DATABASE "DBbiblioteca";
                postgres    false            �            1255    25503    actualizar_promedio_rating()    FUNCTION     >  CREATE FUNCTION public.actualizar_promedio_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Actualizar promedio de la edición
    IF NEW.EdicionID IS NOT NULL THEN
        UPDATE Ediciones
        SET Promedio_Rating = (SELECT AVG(Calificacion) FROM Reseña WHERE EdicionID = NEW.EdicionID)
        WHERE EdicionID = NEW.EdicionID;
    END IF;

    -- Actualizar promedio del libro
    UPDATE Libros
    SET Promedio_Rating = (SELECT AVG(Calificacion) FROM Reseña WHERE LibroID = NEW.LibroID)
    WHERE LibroID = NEW.LibroID;

    RETURN NEW;
END;
$$;
 3   DROP FUNCTION public.actualizar_promedio_rating();
       public          postgres    false            �            1255    25504 #   actualizar_total_prestamos_libros()    FUNCTION       CREATE FUNCTION public.actualizar_total_prestamos_libros() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Libros
    SET Total_Prestamos = Total_Prestamos + 1
    WHERE LibroID = (SELECT LibroID FROM Ediciones WHERE EdicionID = NEW.EdicionID);
    RETURN NEW;
END;
$$;
 :   DROP FUNCTION public.actualizar_total_prestamos_libros();
       public          postgres    false            �            1255    25505    insertar_libro_prestamo()    FUNCTION       CREATE FUNCTION public.insertar_libro_prestamo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO LibroPrestamo (LibroID, PrestamoID)
    VALUES ((SELECT LibroID FROM Ediciones WHERE EdicionID = NEW.EdicionID), NEW.PrestamoID);
    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.insertar_libro_prestamo();
       public          postgres    false            �            1255    25506 &   obtener_total_prestamos_libro(integer) 	   PROCEDURE     4  CREATE PROCEDURE public.obtener_total_prestamos_libro(IN p_id_libro integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_prestamos INT;
    nombre_del_libro VARCHAR(255);
BEGIN
    SELECT COUNT(*), l.Titulo INTO total_prestamos, nombre_del_libro
    FROM Prestamos p
             JOIN LibroPrestamo lp ON p.PrestamoID = lp.PrestamoID
             JOIN Libros l ON lp.LibroID = l.LibroID
    WHERE l.LibroID = p_id_libro
    GROUP BY l.Titulo;

    RAISE NOTICE 'Total de préstamos del libro % (%): %', p_id_libro, nombre_del_libro, total_prestamos;
END;
$$;
 L   DROP PROCEDURE public.obtener_total_prestamos_libro(IN p_id_libro integer);
       public          postgres    false            �            1255    25507 (   obtener_total_prestamos_miembro(integer) 	   PROCEDURE     \  CREATE PROCEDURE public.obtener_total_prestamos_miembro(IN p_id_miembro integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_prestamos INT;
BEGIN
    SELECT COUNT(*) INTO total_prestamos
    FROM Prestamos
    WHERE MiembroID = p_id_miembro;
    RAISE NOTICE 'Total de préstamos para el miembro %: %', p_id_miembro, total_prestamos;
END;
$$;
 P   DROP PROCEDURE public.obtener_total_prestamos_miembro(IN p_id_miembro integer);
       public          postgres    false            �            1255    25508 %   obtener_total_reseñas_libro(integer) 	   PROCEDURE     �  CREATE PROCEDURE public."obtener_total_reseñas_libro"(IN p_id_libro integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_reseñas INT;
    nombre_del_libro VARCHAR(255);
BEGIN
    SELECT COUNT(*), l.Titulo INTO total_reseñas, nombre_del_libro
    FROM Reseña r
             JOIN Libros l ON r.LibroID = l.LibroID
    WHERE l.LibroID = p_id_libro
    GROUP BY l.Titulo;

    RAISE NOTICE 'Total de reseñas del libro % (%): es %', p_id_libro, nombre_del_libro, total_reseñas;
END;
$$;
 M   DROP PROCEDURE public."obtener_total_reseñas_libro"(IN p_id_libro integer);
       public          postgres    false            �            1259    25402    autor    TABLE     �   CREATE TABLE public.autor (
    autorid integer NOT NULL,
    nombre character varying(255) NOT NULL,
    biografia text,
    nacionalidad character varying(100)
);
    DROP TABLE public.autor;
       public         heap    postgres    false            �            1259    25412    autor_autorid_seq    SEQUENCE     �   CREATE SEQUENCE public.autor_autorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.autor_autorid_seq;
       public          postgres    false    215            x           0    0    autor_autorid_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.autor_autorid_seq OWNED BY public.autor.autorid;
          public          postgres    false    217            �            1259    25407 
   categorias    TABLE     �   CREATE TABLE public.categorias (
    categoriaid integer NOT NULL,
    nombre_categoria character varying(100) NOT NULL,
    descripcion text
);
    DROP TABLE public.categorias;
       public         heap    postgres    false            �            1259    25434    categorias_categoriaid_seq    SEQUENCE     �   CREATE SEQUENCE public.categorias_categoriaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.categorias_categoriaid_seq;
       public          postgres    false    216            y           0    0    categorias_categoriaid_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.categorias_categoriaid_seq OWNED BY public.categorias.categoriaid;
          public          postgres    false    226            �            1259    25418 	   ediciones    TABLE     8  CREATE TABLE public.ediciones (
    edicionid integer NOT NULL,
    isbn character varying(20) NOT NULL,
    numero_edicion integer NOT NULL,
    fecha_publicacion date,
    libroid integer NOT NULL,
    proveedorid integer,
    total_prestamos integer DEFAULT 0,
    promedio_rating numeric(2,1) DEFAULT 0.0
);
    DROP TABLE public.ediciones;
       public         heap    postgres    false            �            1259    25423    ediciones_edicionid_seq    SEQUENCE     �   CREATE SEQUENCE public.ediciones_edicionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.ediciones_edicionid_seq;
       public          postgres    false    220            z           0    0    ediciones_edicionid_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.ediciones_edicionid_seq OWNED BY public.ediciones.edicionid;
          public          postgres    false    221            �            1259    25424    editoriales    TABLE     �   CREATE TABLE public.editoriales (
    editorialid integer NOT NULL,
    nombre_editorial character varying(255) NOT NULL,
    direccion text,
    contacto character varying(100)
);
    DROP TABLE public.editoriales;
       public         heap    postgres    false            �            1259    25429    editoriales_editorialid_seq    SEQUENCE     �   CREATE SEQUENCE public.editoriales_editorialid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.editoriales_editorialid_seq;
       public          postgres    false    222            {           0    0    editoriales_editorialid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.editoriales_editorialid_seq OWNED BY public.editoriales.editorialid;
          public          postgres    false    223            �            1259    25430 
   libroautor    TABLE     �   CREATE TABLE public.libroautor (
    libroautorid integer NOT NULL,
    libroid integer NOT NULL,
    autorid integer NOT NULL
);
    DROP TABLE public.libroautor;
       public         heap    postgres    false            �            1259    25433    libroautor_libroautorid_seq    SEQUENCE     �   CREATE SEQUENCE public.libroautor_libroautorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.libroautor_libroautorid_seq;
       public          postgres    false    224            |           0    0    libroautor_libroautorid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.libroautor_libroautorid_seq OWNED BY public.libroautor.libroautorid;
          public          postgres    false    225            �            1259    25435    librocategoria    TABLE     �   CREATE TABLE public.librocategoria (
    librocategoriaid integer NOT NULL,
    libroid integer NOT NULL,
    categoriaid integer NOT NULL
);
 "   DROP TABLE public.librocategoria;
       public         heap    postgres    false            �            1259    25438 #   librocategoria_librocategoriaid_seq    SEQUENCE     �   CREATE SEQUENCE public.librocategoria_librocategoriaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.librocategoria_librocategoriaid_seq;
       public          postgres    false    227            }           0    0 #   librocategoria_librocategoriaid_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.librocategoria_librocategoriaid_seq OWNED BY public.librocategoria.librocategoriaid;
          public          postgres    false    228            �            1259    25439    libroprestamo    TABLE     �   CREATE TABLE public.libroprestamo (
    libroprestamoid integer NOT NULL,
    libroid integer NOT NULL,
    prestamoid integer NOT NULL
);
 !   DROP TABLE public.libroprestamo;
       public         heap    postgres    false            �            1259    25442 !   libroprestamo_libroprestamoid_seq    SEQUENCE     �   CREATE SEQUENCE public.libroprestamo_libroprestamoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.libroprestamo_libroprestamoid_seq;
       public          postgres    false    229            ~           0    0 !   libroprestamo_libroprestamoid_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.libroprestamo_libroprestamoid_seq OWNED BY public.libroprestamo.libroprestamoid;
          public          postgres    false    230            �            1259    25443    libros    TABLE     1  CREATE TABLE public.libros (
    libroid integer NOT NULL,
    titulo character varying(255) NOT NULL,
    genero character varying(100),
    autorid integer NOT NULL,
    editorialid integer,
    categoriaid integer,
    total_prestamos integer DEFAULT 0,
    promedio_rating numeric(2,1) DEFAULT 0.0
);
    DROP TABLE public.libros;
       public         heap    postgres    false            �            1259    25448    libros_libroid_seq    SEQUENCE     �   CREATE SEQUENCE public.libros_libroid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.libros_libroid_seq;
       public          postgres    false    231                       0    0    libros_libroid_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.libros_libroid_seq OWNED BY public.libros.libroid;
          public          postgres    false    232            �            1259    25449    miembros    TABLE     #  CREATE TABLE public.miembros (
    miembroid integer NOT NULL,
    nombre character varying(255) NOT NULL,
    telefono character varying(20),
    direccion text,
    carrera character varying(100),
    semestre integer,
    registro character varying(50),
    usuarioid integer NOT NULL
);
    DROP TABLE public.miembros;
       public         heap    postgres    false            �            1259    25454    miembros_miembroid_seq    SEQUENCE     �   CREATE SEQUENCE public.miembros_miembroid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.miembros_miembroid_seq;
       public          postgres    false    233            �           0    0    miembros_miembroid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.miembros_miembroid_seq OWNED BY public.miembros.miembroid;
          public          postgres    false    234            �            1259    25455 	   prestamos    TABLE     �   CREATE TABLE public.prestamos (
    prestamoid integer NOT NULL,
    miembroid integer NOT NULL,
    edicionid integer NOT NULL,
    fecha_prestamo date NOT NULL,
    fecha_devolucion date,
    estado character varying(50)
);
    DROP TABLE public.prestamos;
       public         heap    postgres    false            �            1259    25458    prestamos_prestamoid_seq    SEQUENCE     �   CREATE SEQUENCE public.prestamos_prestamoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.prestamos_prestamoid_seq;
       public          postgres    false    235            �           0    0    prestamos_prestamoid_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.prestamos_prestamoid_seq OWNED BY public.prestamos.prestamoid;
          public          postgres    false    236            �            1259    25459    proveedores    TABLE     $  CREATE TABLE public.proveedores (
    proveedorid integer NOT NULL,
    nombre_proveedor character varying(255) NOT NULL,
    contacto_proveedor character varying(255),
    correo_proveedor character varying(100),
    telefono_proveedor character varying(20),
    direccion_proveedor text
);
    DROP TABLE public.proveedores;
       public         heap    postgres    false            �            1259    25464    proveedores_proveedorid_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedores_proveedorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.proveedores_proveedorid_seq;
       public          postgres    false    237            �           0    0    proveedores_proveedorid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.proveedores_proveedorid_seq OWNED BY public.proveedores.proveedorid;
          public          postgres    false    238            �            1259    25465    reseña    TABLE     N  CREATE TABLE public."reseña" (
    "reseñaid" integer NOT NULL,
    miembroid integer NOT NULL,
    edicionid integer NOT NULL,
    libroid integer,
    calificacion integer,
    comentario text,
    "fecha_reseña" date NOT NULL,
    CONSTRAINT "reseña_calificacion_check" CHECK (((calificacion >= 1) AND (calificacion <= 5)))
);
    DROP TABLE public."reseña";
       public         heap    postgres    false            �            1259    25471    reseña_reseñaid_seq    SEQUENCE     �   CREATE SEQUENCE public."reseña_reseñaid_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public."reseña_reseñaid_seq";
       public          postgres    false    239            �           0    0    reseña_reseñaid_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."reseña_reseñaid_seq" OWNED BY public."reseña"."reseñaid";
          public          postgres    false    240            �            1259    25472    roles    TABLE     j   CREATE TABLE public.roles (
    rolid integer NOT NULL,
    nombre_rol character varying(100) NOT NULL
);
    DROP TABLE public.roles;
       public         heap    postgres    false            �            1259    25475    roles_rolid_seq    SEQUENCE     �   CREATE SEQUENCE public.roles_rolid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.roles_rolid_seq;
       public          postgres    false    241            �           0    0    roles_rolid_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.roles_rolid_seq OWNED BY public.roles.rolid;
          public          postgres    false    242            �            1259    25476    subscripciones    TABLE     �   CREATE TABLE public.subscripciones (
    subscripcionid integer NOT NULL,
    usuarioid integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    estado character varying(50) DEFAULT 'Activa'::character varying
);
 "   DROP TABLE public.subscripciones;
       public         heap    postgres    false            �            1259    25480 !   subscripciones_subscripcionid_seq    SEQUENCE     �   CREATE SEQUENCE public.subscripciones_subscripcionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.subscripciones_subscripcionid_seq;
       public          postgres    false    243            �           0    0 !   subscripciones_subscripcionid_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.subscripciones_subscripcionid_seq OWNED BY public.subscripciones.subscripcionid;
          public          postgres    false    244            �            1259    25481    useractivitylog    TABLE     �   CREATE TABLE public.useractivitylog (
    id integer NOT NULL,
    userid integer NOT NULL,
    action character varying(255) NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 #   DROP TABLE public.useractivitylog;
       public         heap    postgres    false            �            1259    25485    useractivitylog_id_seq    SEQUENCE     �   CREATE SEQUENCE public.useractivitylog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.useractivitylog_id_seq;
       public          postgres    false    245            �           0    0    useractivitylog_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.useractivitylog_id_seq OWNED BY public.useractivitylog.id;
          public          postgres    false    246            �            1259    25413    usuario    TABLE       CREATE TABLE public.usuario (
    usuarioid integer NOT NULL,
    rolid integer DEFAULT 1 NOT NULL,
    nombre_usuario character varying(100) NOT NULL,
    "contraseña" character varying(100) NOT NULL,
    correo_electronico character varying(100) NOT NULL
);
    DROP TABLE public.usuario;
       public         heap    postgres    false            �            1259    25417    usuario_usuarioid_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_usuarioid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.usuario_usuarioid_seq;
       public          postgres    false    218            �           0    0    usuario_usuarioid_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.usuario_usuarioid_seq OWNED BY public.usuario.usuarioid;
          public          postgres    false    219            k           2604    25486    autor autorid    DEFAULT     n   ALTER TABLE ONLY public.autor ALTER COLUMN autorid SET DEFAULT nextval('public.autor_autorid_seq'::regclass);
 <   ALTER TABLE public.autor ALTER COLUMN autorid DROP DEFAULT;
       public          postgres    false    217    215            l           2604    25487    categorias categoriaid    DEFAULT     �   ALTER TABLE ONLY public.categorias ALTER COLUMN categoriaid SET DEFAULT nextval('public.categorias_categoriaid_seq'::regclass);
 E   ALTER TABLE public.categorias ALTER COLUMN categoriaid DROP DEFAULT;
       public          postgres    false    226    216            o           2604    25488    ediciones edicionid    DEFAULT     z   ALTER TABLE ONLY public.ediciones ALTER COLUMN edicionid SET DEFAULT nextval('public.ediciones_edicionid_seq'::regclass);
 B   ALTER TABLE public.ediciones ALTER COLUMN edicionid DROP DEFAULT;
       public          postgres    false    221    220            r           2604    25489    editoriales editorialid    DEFAULT     �   ALTER TABLE ONLY public.editoriales ALTER COLUMN editorialid SET DEFAULT nextval('public.editoriales_editorialid_seq'::regclass);
 F   ALTER TABLE public.editoriales ALTER COLUMN editorialid DROP DEFAULT;
       public          postgres    false    223    222            s           2604    25490    libroautor libroautorid    DEFAULT     �   ALTER TABLE ONLY public.libroautor ALTER COLUMN libroautorid SET DEFAULT nextval('public.libroautor_libroautorid_seq'::regclass);
 F   ALTER TABLE public.libroautor ALTER COLUMN libroautorid DROP DEFAULT;
       public          postgres    false    225    224            t           2604    25491    librocategoria librocategoriaid    DEFAULT     �   ALTER TABLE ONLY public.librocategoria ALTER COLUMN librocategoriaid SET DEFAULT nextval('public.librocategoria_librocategoriaid_seq'::regclass);
 N   ALTER TABLE public.librocategoria ALTER COLUMN librocategoriaid DROP DEFAULT;
       public          postgres    false    228    227            u           2604    25492    libroprestamo libroprestamoid    DEFAULT     �   ALTER TABLE ONLY public.libroprestamo ALTER COLUMN libroprestamoid SET DEFAULT nextval('public.libroprestamo_libroprestamoid_seq'::regclass);
 L   ALTER TABLE public.libroprestamo ALTER COLUMN libroprestamoid DROP DEFAULT;
       public          postgres    false    230    229            v           2604    25493    libros libroid    DEFAULT     p   ALTER TABLE ONLY public.libros ALTER COLUMN libroid SET DEFAULT nextval('public.libros_libroid_seq'::regclass);
 =   ALTER TABLE public.libros ALTER COLUMN libroid DROP DEFAULT;
       public          postgres    false    232    231            y           2604    25494    miembros miembroid    DEFAULT     x   ALTER TABLE ONLY public.miembros ALTER COLUMN miembroid SET DEFAULT nextval('public.miembros_miembroid_seq'::regclass);
 A   ALTER TABLE public.miembros ALTER COLUMN miembroid DROP DEFAULT;
       public          postgres    false    234    233            z           2604    25495    prestamos prestamoid    DEFAULT     |   ALTER TABLE ONLY public.prestamos ALTER COLUMN prestamoid SET DEFAULT nextval('public.prestamos_prestamoid_seq'::regclass);
 C   ALTER TABLE public.prestamos ALTER COLUMN prestamoid DROP DEFAULT;
       public          postgres    false    236    235            {           2604    25496    proveedores proveedorid    DEFAULT     �   ALTER TABLE ONLY public.proveedores ALTER COLUMN proveedorid SET DEFAULT nextval('public.proveedores_proveedorid_seq'::regclass);
 F   ALTER TABLE public.proveedores ALTER COLUMN proveedorid DROP DEFAULT;
       public          postgres    false    238    237            |           2604    25497    reseña reseñaid    DEFAULT     |   ALTER TABLE ONLY public."reseña" ALTER COLUMN "reseñaid" SET DEFAULT nextval('public."reseña_reseñaid_seq"'::regclass);
 D   ALTER TABLE public."reseña" ALTER COLUMN "reseñaid" DROP DEFAULT;
       public          postgres    false    240    239            }           2604    25498    roles rolid    DEFAULT     j   ALTER TABLE ONLY public.roles ALTER COLUMN rolid SET DEFAULT nextval('public.roles_rolid_seq'::regclass);
 :   ALTER TABLE public.roles ALTER COLUMN rolid DROP DEFAULT;
       public          postgres    false    242    241            ~           2604    25500    subscripciones subscripcionid    DEFAULT     �   ALTER TABLE ONLY public.subscripciones ALTER COLUMN subscripcionid SET DEFAULT nextval('public.subscripciones_subscripcionid_seq'::regclass);
 L   ALTER TABLE public.subscripciones ALTER COLUMN subscripcionid DROP DEFAULT;
       public          postgres    false    244    243            �           2604    25501    useractivitylog id    DEFAULT     x   ALTER TABLE ONLY public.useractivitylog ALTER COLUMN id SET DEFAULT nextval('public.useractivitylog_id_seq'::regclass);
 A   ALTER TABLE public.useractivitylog ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    246    245            m           2604    25502    usuario usuarioid    DEFAULT     v   ALTER TABLE ONLY public.usuario ALTER COLUMN usuarioid SET DEFAULT nextval('public.usuario_usuarioid_seq'::regclass);
 @   ALTER TABLE public.usuario ALTER COLUMN usuarioid DROP DEFAULT;
       public          postgres    false    219    218            R          0    25402    autor 
   TABLE DATA           I   COPY public.autor (autorid, nombre, biografia, nacionalidad) FROM stdin;
    public          postgres    false    215   ��       S          0    25407 
   categorias 
   TABLE DATA           P   COPY public.categorias (categoriaid, nombre_categoria, descripcion) FROM stdin;
    public          postgres    false    216   ��       W          0    25418 	   ediciones 
   TABLE DATA           �   COPY public.ediciones (edicionid, isbn, numero_edicion, fecha_publicacion, libroid, proveedorid, total_prestamos, promedio_rating) FROM stdin;
    public          postgres    false    220   c�       Y          0    25424    editoriales 
   TABLE DATA           Y   COPY public.editoriales (editorialid, nombre_editorial, direccion, contacto) FROM stdin;
    public          postgres    false    222   ��       [          0    25430 
   libroautor 
   TABLE DATA           D   COPY public.libroautor (libroautorid, libroid, autorid) FROM stdin;
    public          postgres    false    224   1�       ^          0    25435    librocategoria 
   TABLE DATA           P   COPY public.librocategoria (librocategoriaid, libroid, categoriaid) FROM stdin;
    public          postgres    false    227   N�       `          0    25439    libroprestamo 
   TABLE DATA           M   COPY public.libroprestamo (libroprestamoid, libroid, prestamoid) FROM stdin;
    public          postgres    false    229   k�       b          0    25443    libros 
   TABLE DATA           ~   COPY public.libros (libroid, titulo, genero, autorid, editorialid, categoriaid, total_prestamos, promedio_rating) FROM stdin;
    public          postgres    false    231   ��       d          0    25449    miembros 
   TABLE DATA           r   COPY public.miembros (miembroid, nombre, telefono, direccion, carrera, semestre, registro, usuarioid) FROM stdin;
    public          postgres    false    233   �       f          0    25455 	   prestamos 
   TABLE DATA           o   COPY public.prestamos (prestamoid, miembroid, edicionid, fecha_prestamo, fecha_devolucion, estado) FROM stdin;
    public          postgres    false    235   *�       h          0    25459    proveedores 
   TABLE DATA           �   COPY public.proveedores (proveedorid, nombre_proveedor, contacto_proveedor, correo_proveedor, telefono_proveedor, direccion_proveedor) FROM stdin;
    public          postgres    false    237   G�       j          0    25465    reseña 
   TABLE DATA           z   COPY public."reseña" ("reseñaid", miembroid, edicionid, libroid, calificacion, comentario, "fecha_reseña") FROM stdin;
    public          postgres    false    239   d�       l          0    25472    roles 
   TABLE DATA           2   COPY public.roles (rolid, nombre_rol) FROM stdin;
    public          postgres    false    241   ��       n          0    25476    subscripciones 
   TABLE DATA           d   COPY public.subscripciones (subscripcionid, usuarioid, fecha_inicio, fecha_fin, estado) FROM stdin;
    public          postgres    false    243   ��       p          0    25481    useractivitylog 
   TABLE DATA           J   COPY public.useractivitylog (id, userid, action, "timestamp") FROM stdin;
    public          postgres    false    245   ��       U          0    25413    usuario 
   TABLE DATA           f   COPY public.usuario (usuarioid, rolid, nombre_usuario, "contraseña", correo_electronico) FROM stdin;
    public          postgres    false    218   ��       �           0    0    autor_autorid_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.autor_autorid_seq', 3, true);
          public          postgres    false    217            �           0    0    categorias_categoriaid_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.categorias_categoriaid_seq', 3, true);
          public          postgres    false    226            �           0    0    ediciones_edicionid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ediciones_edicionid_seq', 3, true);
          public          postgres    false    221            �           0    0    editoriales_editorialid_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.editoriales_editorialid_seq', 3, true);
          public          postgres    false    223            �           0    0    libroautor_libroautorid_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.libroautor_libroautorid_seq', 1, false);
          public          postgres    false    225            �           0    0 #   librocategoria_librocategoriaid_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.librocategoria_librocategoriaid_seq', 1, false);
          public          postgres    false    228            �           0    0 !   libroprestamo_libroprestamoid_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.libroprestamo_libroprestamoid_seq', 1, false);
          public          postgres    false    230            �           0    0    libros_libroid_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.libros_libroid_seq', 7, true);
          public          postgres    false    232            �           0    0    miembros_miembroid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.miembros_miembroid_seq', 1, false);
          public          postgres    false    234            �           0    0    prestamos_prestamoid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.prestamos_prestamoid_seq', 1, false);
          public          postgres    false    236            �           0    0    proveedores_proveedorid_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.proveedores_proveedorid_seq', 1, false);
          public          postgres    false    238            �           0    0    reseña_reseñaid_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."reseña_reseñaid_seq"', 1, false);
          public          postgres    false    240            �           0    0    roles_rolid_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.roles_rolid_seq', 1, false);
          public          postgres    false    242            �           0    0 !   subscripciones_subscripcionid_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.subscripciones_subscripcionid_seq', 1, false);
          public          postgres    false    244            �           0    0    useractivitylog_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.useractivitylog_id_seq', 35, true);
          public          postgres    false    246            �           0    0    usuario_usuarioid_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.usuario_usuarioid_seq', 19, true);
          public          postgres    false    219            �           2606    25510    autor autor_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.autor
    ADD CONSTRAINT autor_pkey PRIMARY KEY (autorid);
 :   ALTER TABLE ONLY public.autor DROP CONSTRAINT autor_pkey;
       public            postgres    false    215            �           2606    25512    categorias categorias_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (categoriaid);
 D   ALTER TABLE ONLY public.categorias DROP CONSTRAINT categorias_pkey;
       public            postgres    false    216            �           2606    25514    ediciones ediciones_isbn_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_isbn_key UNIQUE (isbn);
 F   ALTER TABLE ONLY public.ediciones DROP CONSTRAINT ediciones_isbn_key;
       public            postgres    false    220            �           2606    25516    ediciones ediciones_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_pkey PRIMARY KEY (edicionid);
 B   ALTER TABLE ONLY public.ediciones DROP CONSTRAINT ediciones_pkey;
       public            postgres    false    220            �           2606    25518    editoriales editoriales_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.editoriales
    ADD CONSTRAINT editoriales_pkey PRIMARY KEY (editorialid);
 F   ALTER TABLE ONLY public.editoriales DROP CONSTRAINT editoriales_pkey;
       public            postgres    false    222            �           2606    25520    libroautor libroautor_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_pkey PRIMARY KEY (libroautorid);
 D   ALTER TABLE ONLY public.libroautor DROP CONSTRAINT libroautor_pkey;
       public            postgres    false    224            �           2606    25522 "   librocategoria librocategoria_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_pkey PRIMARY KEY (librocategoriaid);
 L   ALTER TABLE ONLY public.librocategoria DROP CONSTRAINT librocategoria_pkey;
       public            postgres    false    227            �           2606    25524     libroprestamo libroprestamo_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_pkey PRIMARY KEY (libroprestamoid);
 J   ALTER TABLE ONLY public.libroprestamo DROP CONSTRAINT libroprestamo_pkey;
       public            postgres    false    229            �           2606    25526    libros libros_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_pkey PRIMARY KEY (libroid);
 <   ALTER TABLE ONLY public.libros DROP CONSTRAINT libros_pkey;
       public            postgres    false    231            �           2606    25528    miembros miembros_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.miembros
    ADD CONSTRAINT miembros_pkey PRIMARY KEY (miembroid);
 @   ALTER TABLE ONLY public.miembros DROP CONSTRAINT miembros_pkey;
       public            postgres    false    233            �           2606    25530    prestamos prestamos_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_pkey PRIMARY KEY (prestamoid);
 B   ALTER TABLE ONLY public.prestamos DROP CONSTRAINT prestamos_pkey;
       public            postgres    false    235            �           2606    25532    proveedores proveedores_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (proveedorid);
 F   ALTER TABLE ONLY public.proveedores DROP CONSTRAINT proveedores_pkey;
       public            postgres    false    237            �           2606    25534    reseña reseña_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_pkey" PRIMARY KEY ("reseñaid");
 B   ALTER TABLE ONLY public."reseña" DROP CONSTRAINT "reseña_pkey";
       public            postgres    false    239            �           2606    25536    roles roles_nombre_rol_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nombre_rol_key UNIQUE (nombre_rol);
 D   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_nombre_rol_key;
       public            postgres    false    241            �           2606    25538    roles roles_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolid);
 :   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_pkey;
       public            postgres    false    241            �           2606    25540 "   subscripciones subscripciones_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.subscripciones
    ADD CONSTRAINT subscripciones_pkey PRIMARY KEY (subscripcionid);
 L   ALTER TABLE ONLY public.subscripciones DROP CONSTRAINT subscripciones_pkey;
       public            postgres    false    243            �           2606    25542 $   useractivitylog useractivitylog_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.useractivitylog
    ADD CONSTRAINT useractivitylog_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.useractivitylog DROP CONSTRAINT useractivitylog_pkey;
       public            postgres    false    245            �           2606    25544 "   usuario usuario_nombre_usuario_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nombre_usuario_key UNIQUE (nombre_usuario);
 L   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_nombre_usuario_key;
       public            postgres    false    218            �           2606    25546    usuario usuario_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (usuarioid);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    218            �           1259    25547    idx_ediciones_id_libro    INDEX     O   CREATE INDEX idx_ediciones_id_libro ON public.ediciones USING btree (libroid);
 *   DROP INDEX public.idx_ediciones_id_libro;
       public            postgres    false    220            �           1259    25548    idx_libros_id_autor    INDEX     I   CREATE INDEX idx_libros_id_autor ON public.libros USING btree (autorid);
 '   DROP INDEX public.idx_libros_id_autor;
       public            postgres    false    231            �           1259    25549    idx_prestamos_id_edicion    INDEX     S   CREATE INDEX idx_prestamos_id_edicion ON public.prestamos USING btree (edicionid);
 ,   DROP INDEX public.idx_prestamos_id_edicion;
       public            postgres    false    235            �           1259    25550    idx_prestamos_id_miembro    INDEX     S   CREATE INDEX idx_prestamos_id_miembro ON public.prestamos USING btree (miembroid);
 ,   DROP INDEX public.idx_prestamos_id_miembro;
       public            postgres    false    235            �           2620    25551 %   reseña tg_actualizar_promedio_rating    TRIGGER     �   CREATE TRIGGER tg_actualizar_promedio_rating AFTER INSERT ON public."reseña" FOR EACH ROW EXECUTE FUNCTION public.actualizar_promedio_rating();
 @   DROP TRIGGER tg_actualizar_promedio_rating ON public."reseña";
       public          postgres    false    247    239            �           2620    25552 .   prestamos tg_actualizar_total_prestamos_libros    TRIGGER     �   CREATE TRIGGER tg_actualizar_total_prestamos_libros AFTER INSERT ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.actualizar_total_prestamos_libros();
 G   DROP TRIGGER tg_actualizar_total_prestamos_libros ON public.prestamos;
       public          postgres    false    235    248            �           2620    25553 $   prestamos tg_insertar_libro_prestamo    TRIGGER     �   CREATE TRIGGER tg_insertar_libro_prestamo AFTER INSERT ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.insertar_libro_prestamo();
 =   DROP TRIGGER tg_insertar_libro_prestamo ON public.prestamos;
       public          postgres    false    249    235            �           2606    25554     ediciones ediciones_libroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);
 J   ALTER TABLE ONLY public.ediciones DROP CONSTRAINT ediciones_libroid_fkey;
       public          postgres    false    231    4762    220            �           2606    25559 $   ediciones ediciones_proveedorid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_proveedorid_fkey FOREIGN KEY (proveedorid) REFERENCES public.proveedores(proveedorid);
 N   ALTER TABLE ONLY public.ediciones DROP CONSTRAINT ediciones_proveedorid_fkey;
       public          postgres    false    4770    220    237            �           2606    25564 "   libroautor libroautor_autorid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_autorid_fkey FOREIGN KEY (autorid) REFERENCES public.autor(autorid);
 L   ALTER TABLE ONLY public.libroautor DROP CONSTRAINT libroautor_autorid_fkey;
       public          postgres    false    4740    215    224            �           2606    25569 "   libroautor libroautor_libroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);
 L   ALTER TABLE ONLY public.libroautor DROP CONSTRAINT libroautor_libroid_fkey;
       public          postgres    false    4762    231    224            �           2606    25574 .   librocategoria librocategoria_categoriaid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_categoriaid_fkey FOREIGN KEY (categoriaid) REFERENCES public.categorias(categoriaid);
 X   ALTER TABLE ONLY public.librocategoria DROP CONSTRAINT librocategoria_categoriaid_fkey;
       public          postgres    false    4742    216    227            �           2606    25579 *   librocategoria librocategoria_libroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);
 T   ALTER TABLE ONLY public.librocategoria DROP CONSTRAINT librocategoria_libroid_fkey;
       public          postgres    false    227    4762    231            �           2606    25584 (   libroprestamo libroprestamo_libroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);
 R   ALTER TABLE ONLY public.libroprestamo DROP CONSTRAINT libroprestamo_libroid_fkey;
       public          postgres    false    4762    229    231            �           2606    25589 +   libroprestamo libroprestamo_prestamoid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_prestamoid_fkey FOREIGN KEY (prestamoid) REFERENCES public.prestamos(prestamoid);
 U   ALTER TABLE ONLY public.libroprestamo DROP CONSTRAINT libroprestamo_prestamoid_fkey;
       public          postgres    false    4768    235    229            �           2606    25594    libros libros_autorid_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_autorid_fkey FOREIGN KEY (autorid) REFERENCES public.autor(autorid);
 D   ALTER TABLE ONLY public.libros DROP CONSTRAINT libros_autorid_fkey;
       public          postgres    false    4740    231    215            �           2606    25599    libros libros_categoriaid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_categoriaid_fkey FOREIGN KEY (categoriaid) REFERENCES public.categorias(categoriaid);
 H   ALTER TABLE ONLY public.libros DROP CONSTRAINT libros_categoriaid_fkey;
       public          postgres    false    216    4742    231            �           2606    25604    libros libros_editorialid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_editorialid_fkey FOREIGN KEY (editorialid) REFERENCES public.editoriales(editorialid);
 H   ALTER TABLE ONLY public.libros DROP CONSTRAINT libros_editorialid_fkey;
       public          postgres    false    231    222    4753            �           2606    25609     miembros miembros_usuarioid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.miembros
    ADD CONSTRAINT miembros_usuarioid_fkey FOREIGN KEY (usuarioid) REFERENCES public.usuario(usuarioid);
 J   ALTER TABLE ONLY public.miembros DROP CONSTRAINT miembros_usuarioid_fkey;
       public          postgres    false    218    233    4746            �           2606    25614 "   prestamos prestamos_edicionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_edicionid_fkey FOREIGN KEY (edicionid) REFERENCES public.ediciones(edicionid);
 L   ALTER TABLE ONLY public.prestamos DROP CONSTRAINT prestamos_edicionid_fkey;
       public          postgres    false    220    235    4750            �           2606    25619 "   prestamos prestamos_miembroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_miembroid_fkey FOREIGN KEY (miembroid) REFERENCES public.miembros(miembroid);
 L   ALTER TABLE ONLY public.prestamos DROP CONSTRAINT prestamos_miembroid_fkey;
       public          postgres    false    233    4764    235            �           2606    25624    reseña reseña_edicionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_edicionid_fkey" FOREIGN KEY (edicionid) REFERENCES public.ediciones(edicionid);
 L   ALTER TABLE ONLY public."reseña" DROP CONSTRAINT "reseña_edicionid_fkey";
       public          postgres    false    220    239    4750            �           2606    25629    reseña reseña_libroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_libroid_fkey" FOREIGN KEY (libroid) REFERENCES public.libros(libroid);
 J   ALTER TABLE ONLY public."reseña" DROP CONSTRAINT "reseña_libroid_fkey";
       public          postgres    false    239    231    4762            �           2606    25634    reseña reseña_miembroid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_miembroid_fkey" FOREIGN KEY (miembroid) REFERENCES public.miembros(miembroid);
 L   ALTER TABLE ONLY public."reseña" DROP CONSTRAINT "reseña_miembroid_fkey";
       public          postgres    false    233    239    4764            �           2606    25639 ,   subscripciones subscripciones_usuarioid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.subscripciones
    ADD CONSTRAINT subscripciones_usuarioid_fkey FOREIGN KEY (usuarioid) REFERENCES public.usuario(usuarioid);
 V   ALTER TABLE ONLY public.subscripciones DROP CONSTRAINT subscripciones_usuarioid_fkey;
       public          postgres    false    218    4746    243            �           2606    25644    usuario usuario_rolid_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_rolid_fkey FOREIGN KEY (rolid) REFERENCES public.roles(rolid);
 D   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_rolid_fkey;
       public          postgres    false    218    241    4776            R   �   x�ENMJ1^'�x(��U� �ٹ��<�i&��z�����\~�ߝ�␅#m�}��^�5��i��T��5�� H�"̝	L�Dh_Z:*9 8����{��v��z��&��9�2U�5�GOEP�zD�z�Z9;�gIJc����<�Ӻ�QO���T��½�/����{i߉.�4�	������Ggߜ���]      S   �   x�M�A
�0D��)�	
���B<����W>4?�Ģ�� ]���)(���y��]�,�Y�3�B��Ptɳ�et~�*�
�Y�jĤ�4 cl*F�a,���K]n���"lq��}˝?�V��?°�~�𰱍5��6��H&	��R��/��y�?WJ�      W      x������ � �      Y   �   x�M�M
�0@�ur�9@)��-.��]�L���N���׏��޺��� M��I����|�`	N8qU��J'}A�@n�덪f�$�S7�xw�v+���,�gB���|3F4c���rڪ��"���в<2�[�Bυ,�>�\s��F>G}      [      x������ � �      ^      x������ � �      `      x������ � �      b   u   x�3�t�L�Sp<�1�X!%U!8?'5%1��/�,5'��8���8=��*�KJR�*r2SS��2s���s8��J��M�4Bc�VsΒ������qqq 9$�      d      x������ � �      f      x������ � �      h      x������ � �      j      x������ � �      l   :   x�3�-.M,���2���L�M*��2�t�-�IML��2�tL����,.)r��b���� �9�      n      x������ � �      p   �  x�����0Fks
/pER�M}����q6�Y,�ݥ� �z���O��������u�q�>n���?�!�7�7�+�T�X�IrB�N,.�!ƕc�L!��P�p�	�9����j�)�Ι#aՈI]#�%!�j�T�I: OjhNV� e�:�ф�v����N"�����|r.�ֈBm��e���1ɑ��X�HM�*��6���d�$H�L|`��ؤD�b���D�a�����X���h�@~#���,��:B����Y
��~-��(.������Bﰈ��B�Br���
���W��,6r�b[Dh�X�b#��_H>�1w��a�As"2�}�e�d� ��H#y��k`�L_�>��p!Q�����"�cN�P�^~#k��d�}.m��Ez�{^���&��_��{���������������2=1�B�@y#������w�����      U     x�M�˖�8�1�5m���3E-QP/�'	����cg}�Ͽ���5"'ش̧ >��'޺{SVd�@�*Yq����~���&2��"%Y�Y)emG�є�Xʴ�0��eNؐ��gx�CaKj�EG=.�M�z6�A;3� �(�-��Jj�K��n��z��AV��� ���3FbET��/�%P>�f����b����o��O�Q��\�v�*�X��K��:G���0_D$���x�{f�ba�v�W�j�ZT���6!w���jXV��z����d7g4 F-yǥo����[��9�eP�ی84��k`�ee�ӓ�UM���U���@�o�6߱�#���(�m�RV��v(��^�W��A�{�a.��l[����C��㱴\�O�K����1vX�""/��y\�X}:�g�}*��\�aA�z� պa�,��Mک	�ծ|�&����}��\�te�j9L� 8�0������� �z�@z�^  �2r�<��gv�d� �(�3iބ��`�+�^���]�~���fW���,X�VɄ	.�C���W�þ!w���P��;�#:OhL񏯎~N��n�O������\�Y�6x�؝V�}S/�G�u>�k�s�|.Jq�I��H���`��𳑯�_�4;ٱ�I%�~ӥ�����0�LY�59G2�Rs�`g�f�ر�Fa���G�%aޓ��&�YQ�"��]�{T8�=���:���`���vк�Eմc�n��D:Mn!���R���Ќ�)@���/�����Xo>     