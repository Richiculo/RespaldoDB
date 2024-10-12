--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: actualizar_promedio_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_promedio_rating() RETURNS trigger
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


ALTER FUNCTION public.actualizar_promedio_rating() OWNER TO postgres;

--
-- Name: actualizar_total_prestamos_libros(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_total_prestamos_libros() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Libros
    SET Total_Prestamos = Total_Prestamos + 1
    WHERE LibroID = (SELECT LibroID FROM Ediciones WHERE EdicionID = NEW.EdicionID);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_total_prestamos_libros() OWNER TO postgres;

--
-- Name: insertar_libro_prestamo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertar_libro_prestamo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO LibroPrestamo (LibroID, PrestamoID)
    VALUES ((SELECT LibroID FROM Ediciones WHERE EdicionID = NEW.EdicionID), NEW.PrestamoID);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insertar_libro_prestamo() OWNER TO postgres;

--
-- Name: obtener_total_prestamos_libro(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.obtener_total_prestamos_libro(IN p_id_libro integer)
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


ALTER PROCEDURE public.obtener_total_prestamos_libro(IN p_id_libro integer) OWNER TO postgres;

--
-- Name: obtener_total_prestamos_miembro(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.obtener_total_prestamos_miembro(IN p_id_miembro integer)
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


ALTER PROCEDURE public.obtener_total_prestamos_miembro(IN p_id_miembro integer) OWNER TO postgres;

--
-- Name: obtener_total_reseñas_libro(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public."obtener_total_reseñas_libro"(IN p_id_libro integer)
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


ALTER PROCEDURE public."obtener_total_reseñas_libro"(IN p_id_libro integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: autor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.autor (
    autorid integer NOT NULL,
    nombre character varying(255) NOT NULL,
    biografia text,
    nacionalidad character varying(100)
);


ALTER TABLE public.autor OWNER TO postgres;

--
-- Name: autor_autorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.autor_autorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.autor_autorid_seq OWNER TO postgres;

--
-- Name: autor_autorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.autor_autorid_seq OWNED BY public.autor.autorid;


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    categoriaid integer NOT NULL,
    nombre_categoria character varying(100) NOT NULL,
    descripcion text
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- Name: categorias_categoriaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_categoriaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_categoriaid_seq OWNER TO postgres;

--
-- Name: categorias_categoriaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_categoriaid_seq OWNED BY public.categorias.categoriaid;


--
-- Name: ediciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ediciones (
    edicionid integer NOT NULL,
    isbn character varying(20) NOT NULL,
    numero_edicion integer NOT NULL,
    fecha_publicacion date,
    libroid integer NOT NULL,
    proveedorid integer,
    total_prestamos integer DEFAULT 0,
    promedio_rating numeric(2,1) DEFAULT 0.0
);


ALTER TABLE public.ediciones OWNER TO postgres;

--
-- Name: ediciones_edicionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ediciones_edicionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ediciones_edicionid_seq OWNER TO postgres;

--
-- Name: ediciones_edicionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ediciones_edicionid_seq OWNED BY public.ediciones.edicionid;


--
-- Name: editoriales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.editoriales (
    editorialid integer NOT NULL,
    nombre_editorial character varying(255) NOT NULL,
    direccion text,
    contacto character varying(100)
);


ALTER TABLE public.editoriales OWNER TO postgres;

--
-- Name: editoriales_editorialid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.editoriales_editorialid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.editoriales_editorialid_seq OWNER TO postgres;

--
-- Name: editoriales_editorialid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.editoriales_editorialid_seq OWNED BY public.editoriales.editorialid;


--
-- Name: libroautor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.libroautor (
    libroautorid integer NOT NULL,
    libroid integer NOT NULL,
    autorid integer NOT NULL
);


ALTER TABLE public.libroautor OWNER TO postgres;

--
-- Name: libroautor_libroautorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.libroautor_libroautorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.libroautor_libroautorid_seq OWNER TO postgres;

--
-- Name: libroautor_libroautorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.libroautor_libroautorid_seq OWNED BY public.libroautor.libroautorid;


--
-- Name: librocategoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.librocategoria (
    librocategoriaid integer NOT NULL,
    libroid integer NOT NULL,
    categoriaid integer NOT NULL
);


ALTER TABLE public.librocategoria OWNER TO postgres;

--
-- Name: librocategoria_librocategoriaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.librocategoria_librocategoriaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.librocategoria_librocategoriaid_seq OWNER TO postgres;

--
-- Name: librocategoria_librocategoriaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.librocategoria_librocategoriaid_seq OWNED BY public.librocategoria.librocategoriaid;


--
-- Name: libroprestamo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.libroprestamo (
    libroprestamoid integer NOT NULL,
    libroid integer NOT NULL,
    prestamoid integer NOT NULL
);


ALTER TABLE public.libroprestamo OWNER TO postgres;

--
-- Name: libroprestamo_libroprestamoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.libroprestamo_libroprestamoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.libroprestamo_libroprestamoid_seq OWNER TO postgres;

--
-- Name: libroprestamo_libroprestamoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.libroprestamo_libroprestamoid_seq OWNED BY public.libroprestamo.libroprestamoid;


--
-- Name: libros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.libros (
    libroid integer NOT NULL,
    titulo character varying(255) NOT NULL,
    genero character varying(100),
    autorid integer NOT NULL,
    editorialid integer,
    categoriaid integer,
    total_prestamos integer DEFAULT 0,
    promedio_rating numeric(2,1) DEFAULT 0.0
);


ALTER TABLE public.libros OWNER TO postgres;

--
-- Name: libros_libroid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.libros_libroid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.libros_libroid_seq OWNER TO postgres;

--
-- Name: libros_libroid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.libros_libroid_seq OWNED BY public.libros.libroid;


--
-- Name: miembros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.miembros (
    miembroid integer NOT NULL,
    nombre character varying(255) NOT NULL,
    telefono character varying(20),
    direccion text,
    carrera character varying(100),
    semestre integer,
    registro character varying(50),
    usuarioid integer NOT NULL
);


ALTER TABLE public.miembros OWNER TO postgres;

--
-- Name: miembros_miembroid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.miembros_miembroid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.miembros_miembroid_seq OWNER TO postgres;

--
-- Name: miembros_miembroid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.miembros_miembroid_seq OWNED BY public.miembros.miembroid;


--
-- Name: prestamos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prestamos (
    prestamoid integer NOT NULL,
    miembroid integer NOT NULL,
    edicionid integer NOT NULL,
    fecha_prestamo date NOT NULL,
    fecha_devolucion date,
    estado character varying(50)
);


ALTER TABLE public.prestamos OWNER TO postgres;

--
-- Name: prestamos_prestamoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prestamos_prestamoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prestamos_prestamoid_seq OWNER TO postgres;

--
-- Name: prestamos_prestamoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prestamos_prestamoid_seq OWNED BY public.prestamos.prestamoid;


--
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    proveedorid integer NOT NULL,
    nombre_proveedor character varying(255) NOT NULL,
    contacto_proveedor character varying(255),
    correo_proveedor character varying(100),
    telefono_proveedor character varying(20),
    direccion_proveedor text
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- Name: proveedores_proveedorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedores_proveedorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proveedores_proveedorid_seq OWNER TO postgres;

--
-- Name: proveedores_proveedorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedores_proveedorid_seq OWNED BY public.proveedores.proveedorid;


--
-- Name: reseña; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."reseña" (
    "reseñaid" integer NOT NULL,
    miembroid integer NOT NULL,
    edicionid integer NOT NULL,
    libroid integer,
    calificacion integer,
    comentario text,
    "fecha_reseña" date NOT NULL,
    CONSTRAINT "reseña_calificacion_check" CHECK (((calificacion >= 1) AND (calificacion <= 5)))
);


ALTER TABLE public."reseña" OWNER TO postgres;

--
-- Name: reseña_reseñaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."reseña_reseñaid_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."reseña_reseñaid_seq" OWNER TO postgres;

--
-- Name: reseña_reseñaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."reseña_reseñaid_seq" OWNED BY public."reseña"."reseñaid";


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    rolid integer NOT NULL,
    nombre_rol character varying(100) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_rolid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_rolid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_rolid_seq OWNER TO postgres;

--
-- Name: roles_rolid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_rolid_seq OWNED BY public.roles.rolid;


--
-- Name: subscripciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscripciones (
    subscripcionid integer NOT NULL,
    usuarioid integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    estado character varying(50) DEFAULT 'Activa'::character varying
);


ALTER TABLE public.subscripciones OWNER TO postgres;

--
-- Name: subscripciones_subscripcionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscripciones_subscripcionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscripciones_subscripcionid_seq OWNER TO postgres;

--
-- Name: subscripciones_subscripcionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subscripciones_subscripcionid_seq OWNED BY public.subscripciones.subscripcionid;


--
-- Name: useractivitylog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useractivitylog (
    id integer NOT NULL,
    userid integer NOT NULL,
    action character varying(255) NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.useractivitylog OWNER TO postgres;

--
-- Name: useractivitylog_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useractivitylog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.useractivitylog_id_seq OWNER TO postgres;

--
-- Name: useractivitylog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useractivitylog_id_seq OWNED BY public.useractivitylog.id;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    usuarioid integer NOT NULL,
    rolid integer DEFAULT 1 NOT NULL,
    nombre_usuario character varying(100) NOT NULL,
    "contraseña" character varying(100) NOT NULL,
    correo_electronico character varying(100) NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: usuario_usuarioid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_usuarioid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_usuarioid_seq OWNER TO postgres;

--
-- Name: usuario_usuarioid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_usuarioid_seq OWNED BY public.usuario.usuarioid;


--
-- Name: autor autorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.autor ALTER COLUMN autorid SET DEFAULT nextval('public.autor_autorid_seq'::regclass);


--
-- Name: categorias categoriaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN categoriaid SET DEFAULT nextval('public.categorias_categoriaid_seq'::regclass);


--
-- Name: ediciones edicionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ediciones ALTER COLUMN edicionid SET DEFAULT nextval('public.ediciones_edicionid_seq'::regclass);


--
-- Name: editoriales editorialid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.editoriales ALTER COLUMN editorialid SET DEFAULT nextval('public.editoriales_editorialid_seq'::regclass);


--
-- Name: libroautor libroautorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroautor ALTER COLUMN libroautorid SET DEFAULT nextval('public.libroautor_libroautorid_seq'::regclass);


--
-- Name: librocategoria librocategoriaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librocategoria ALTER COLUMN librocategoriaid SET DEFAULT nextval('public.librocategoria_librocategoriaid_seq'::regclass);


--
-- Name: libroprestamo libroprestamoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroprestamo ALTER COLUMN libroprestamoid SET DEFAULT nextval('public.libroprestamo_libroprestamoid_seq'::regclass);


--
-- Name: libros libroid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libros ALTER COLUMN libroid SET DEFAULT nextval('public.libros_libroid_seq'::regclass);


--
-- Name: miembros miembroid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembros ALTER COLUMN miembroid SET DEFAULT nextval('public.miembros_miembroid_seq'::regclass);


--
-- Name: prestamos prestamoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos ALTER COLUMN prestamoid SET DEFAULT nextval('public.prestamos_prestamoid_seq'::regclass);


--
-- Name: proveedores proveedorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores ALTER COLUMN proveedorid SET DEFAULT nextval('public.proveedores_proveedorid_seq'::regclass);


--
-- Name: reseña reseñaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseña" ALTER COLUMN "reseñaid" SET DEFAULT nextval('public."reseña_reseñaid_seq"'::regclass);


--
-- Name: roles rolid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN rolid SET DEFAULT nextval('public.roles_rolid_seq'::regclass);


--
-- Name: subscripciones subscripcionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscripciones ALTER COLUMN subscripcionid SET DEFAULT nextval('public.subscripciones_subscripcionid_seq'::regclass);


--
-- Name: useractivitylog id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivitylog ALTER COLUMN id SET DEFAULT nextval('public.useractivitylog_id_seq'::regclass);


--
-- Name: usuario usuarioid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN usuarioid SET DEFAULT nextval('public.usuario_usuarioid_seq'::regclass);


--
-- Data for Name: autor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.autor (autorid, nombre, biografia, nacionalidad) FROM stdin;
1	Gabriel García Márquez	Escritor colombiano, autor de Cien años de soledad.	Colombia
2	J.K. Rowling	Autora británica de la saga Harry Potter.	Reino Unido
3	Isaac Asimov	Escritor estadounidense de ciencia ficción y divulgación científica.	EE.UU.
\.


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (categoriaid, nombre_categoria, descripcion) FROM stdin;
1	Novela	Libros de narrativa extensa.
2	Ciencia Ficción	Historias basadas en avances científicos y tecnológicos.
3	Fantasía	Historias ambientadas en mundos imaginarios con elementos mágicos.
\.


--
-- Data for Name: ediciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ediciones (edicionid, isbn, numero_edicion, fecha_publicacion, libroid, proveedorid, total_prestamos, promedio_rating) FROM stdin;
\.


--
-- Data for Name: editoriales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.editoriales (editorialid, nombre_editorial, direccion, contacto) FROM stdin;
1	Editorial Sudamericana	Av. de Mayo, Buenos Aires	editorial@sudamericana.com
2	Bloomsbury Publishing	50 Bedford Square, Londres	contact@bloomsbury.com
3	Random House	New York, NY	info@randomhouse.com
\.


--
-- Data for Name: libroautor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.libroautor (libroautorid, libroid, autorid) FROM stdin;
\.


--
-- Data for Name: librocategoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.librocategoria (librocategoriaid, libroid, categoriaid) FROM stdin;
\.


--
-- Data for Name: libroprestamo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.libroprestamo (libroprestamoid, libroid, prestamoid) FROM stdin;
\.


--
-- Data for Name: libros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.libros (libroid, titulo, genero, autorid, editorialid, categoriaid, total_prestamos, promedio_rating) FROM stdin;
1	Cien Años de Soledad	Novela	1	1	1	0	0.0
2	Harry Potter y la Piedra Filosofal	Fantasía	2	2	3	0	0.0
7	test	test	2	3	3	0	0.0
\.


--
-- Data for Name: miembros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.miembros (miembroid, nombre, telefono, direccion, carrera, semestre, registro, usuarioid) FROM stdin;
\.


--
-- Data for Name: prestamos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prestamos (prestamoid, miembroid, edicionid, fecha_prestamo, fecha_devolucion, estado) FROM stdin;
\.


--
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedores (proveedorid, nombre_proveedor, contacto_proveedor, correo_proveedor, telefono_proveedor, direccion_proveedor) FROM stdin;
\.


--
-- Data for Name: reseña; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."reseña" ("reseñaid", miembroid, edicionid, libroid, calificacion, comentario, "fecha_reseña") FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (rolid, nombre_rol) FROM stdin;
1	Usuario
2	Miembro
3	Empleado
4	Administrador
\.


--
-- Data for Name: subscripciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscripciones (subscripcionid, usuarioid, fecha_inicio, fecha_fin, estado) FROM stdin;
\.


--
-- Data for Name: useractivitylog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.useractivitylog (id, userid, action, "timestamp") FROM stdin;
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (usuarioid, rolid, nombre_usuario, "contraseña", correo_electronico) FROM stdin;
2	2	usuarioTest	$2a$10$mKSNJ676VIih84Lfg.6KfOxyOVi06uL2nhoiiLbW7p6BMoNd5.q.u	test@ejemplo.com
10	1	RirchardVO	$2a$10$LkdnPPkbUIKEgelCn.rxxOPiEvy38JOfieBvGmKo4T0ZLoomUF4he	rvargasosinaga@gmail.com
11	1	victorL	$2a$10$dymnHGyRBy.dHat9JqbgquufQtiF/puJ.CmGBZ/7hUQ6o.bjrSniq	victor@gmail.com
9	4	AndresSa	$2a$10$eIhL2u1f49AqsYf3tH8J6elGIlK2UWV0xdrBI0HoYFM3YqpPf7L5C	oerlinker@gmail.com
12	1	AdolfoSA	$2a$10$1SW.e7Lm8/zMw8y7x8q.Lu7LRtKgokaNYDrBaLLv1MUrAHfvZJ.GW	asafito@gmail.com
14	1	test	$2a$10$VOhmLApPRoojje3z2Z9oPucekYbINb7DIuTx/KnqroLhXFqHC9zu2	testuser@gmial.com
13	3	IvanS	$2a$10$La3XpqYvOPu.vHUfloSB/Oz21yUwJClq1ZmjKrJc4SSEQqiuwwCLS	ivanSuarez@gmail.com
15	1	cpando	$2a$10$PMU/hPLyh9kjBk53Mtl61enoe8QBQahBvzKCpsLR/0t5JaLDMpwcG	camilapando1@gmail.com
\.


--
-- Name: autor_autorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.autor_autorid_seq', 3, true);


--
-- Name: categorias_categoriaid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_categoriaid_seq', 3, true);


--
-- Name: ediciones_edicionid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ediciones_edicionid_seq', 3, true);


--
-- Name: editoriales_editorialid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.editoriales_editorialid_seq', 3, true);


--
-- Name: libroautor_libroautorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.libroautor_libroautorid_seq', 1, false);


--
-- Name: librocategoria_librocategoriaid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.librocategoria_librocategoriaid_seq', 1, false);


--
-- Name: libroprestamo_libroprestamoid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.libroprestamo_libroprestamoid_seq', 1, false);


--
-- Name: libros_libroid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.libros_libroid_seq', 7, true);


--
-- Name: miembros_miembroid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.miembros_miembroid_seq', 1, false);


--
-- Name: prestamos_prestamoid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prestamos_prestamoid_seq', 1, false);


--
-- Name: proveedores_proveedorid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedores_proveedorid_seq', 1, false);


--
-- Name: reseña_reseñaid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."reseña_reseñaid_seq"', 1, false);


--
-- Name: roles_rolid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_rolid_seq', 1, false);


--
-- Name: subscripciones_subscripcionid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscripciones_subscripcionid_seq', 1, false);


--
-- Name: useractivitylog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useractivitylog_id_seq', 1, false);


--
-- Name: usuario_usuarioid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_usuarioid_seq', 15, true);


--
-- Name: autor autor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.autor
    ADD CONSTRAINT autor_pkey PRIMARY KEY (autorid);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (categoriaid);


--
-- Name: ediciones ediciones_isbn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_isbn_key UNIQUE (isbn);


--
-- Name: ediciones ediciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_pkey PRIMARY KEY (edicionid);


--
-- Name: editoriales editoriales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.editoriales
    ADD CONSTRAINT editoriales_pkey PRIMARY KEY (editorialid);


--
-- Name: libroautor libroautor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_pkey PRIMARY KEY (libroautorid);


--
-- Name: librocategoria librocategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_pkey PRIMARY KEY (librocategoriaid);


--
-- Name: libroprestamo libroprestamo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_pkey PRIMARY KEY (libroprestamoid);


--
-- Name: libros libros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_pkey PRIMARY KEY (libroid);


--
-- Name: miembros miembros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembros
    ADD CONSTRAINT miembros_pkey PRIMARY KEY (miembroid);


--
-- Name: prestamos prestamos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_pkey PRIMARY KEY (prestamoid);


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (proveedorid);


--
-- Name: reseña reseña_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_pkey" PRIMARY KEY ("reseñaid");


--
-- Name: roles roles_nombre_rol_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nombre_rol_key UNIQUE (nombre_rol);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolid);


--
-- Name: subscripciones subscripciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscripciones
    ADD CONSTRAINT subscripciones_pkey PRIMARY KEY (subscripcionid);


--
-- Name: useractivitylog useractivitylog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivitylog
    ADD CONSTRAINT useractivitylog_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_nombre_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nombre_usuario_key UNIQUE (nombre_usuario);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (usuarioid);


--
-- Name: idx_ediciones_id_libro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ediciones_id_libro ON public.ediciones USING btree (libroid);


--
-- Name: idx_libros_id_autor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_libros_id_autor ON public.libros USING btree (autorid);


--
-- Name: idx_prestamos_id_edicion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prestamos_id_edicion ON public.prestamos USING btree (edicionid);


--
-- Name: idx_prestamos_id_miembro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prestamos_id_miembro ON public.prestamos USING btree (miembroid);


--
-- Name: reseña tg_actualizar_promedio_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_promedio_rating AFTER INSERT ON public."reseña" FOR EACH ROW EXECUTE FUNCTION public.actualizar_promedio_rating();


--
-- Name: prestamos tg_actualizar_total_prestamos_libros; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_total_prestamos_libros AFTER INSERT ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.actualizar_total_prestamos_libros();


--
-- Name: prestamos tg_insertar_libro_prestamo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_insertar_libro_prestamo AFTER INSERT ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.insertar_libro_prestamo();


--
-- Name: ediciones ediciones_libroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);


--
-- Name: ediciones ediciones_proveedorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ediciones
    ADD CONSTRAINT ediciones_proveedorid_fkey FOREIGN KEY (proveedorid) REFERENCES public.proveedores(proveedorid);


--
-- Name: libroautor libroautor_autorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_autorid_fkey FOREIGN KEY (autorid) REFERENCES public.autor(autorid);


--
-- Name: libroautor libroautor_libroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroautor
    ADD CONSTRAINT libroautor_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);


--
-- Name: librocategoria librocategoria_categoriaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_categoriaid_fkey FOREIGN KEY (categoriaid) REFERENCES public.categorias(categoriaid);


--
-- Name: librocategoria librocategoria_libroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librocategoria
    ADD CONSTRAINT librocategoria_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);


--
-- Name: libroprestamo libroprestamo_libroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_libroid_fkey FOREIGN KEY (libroid) REFERENCES public.libros(libroid);


--
-- Name: libroprestamo libroprestamo_prestamoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libroprestamo
    ADD CONSTRAINT libroprestamo_prestamoid_fkey FOREIGN KEY (prestamoid) REFERENCES public.prestamos(prestamoid);


--
-- Name: libros libros_autorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_autorid_fkey FOREIGN KEY (autorid) REFERENCES public.autor(autorid);


--
-- Name: libros libros_categoriaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_categoriaid_fkey FOREIGN KEY (categoriaid) REFERENCES public.categorias(categoriaid);


--
-- Name: libros libros_editorialid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libros
    ADD CONSTRAINT libros_editorialid_fkey FOREIGN KEY (editorialid) REFERENCES public.editoriales(editorialid);


--
-- Name: miembros miembros_usuarioid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembros
    ADD CONSTRAINT miembros_usuarioid_fkey FOREIGN KEY (usuarioid) REFERENCES public.usuario(usuarioid);


--
-- Name: prestamos prestamos_edicionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_edicionid_fkey FOREIGN KEY (edicionid) REFERENCES public.ediciones(edicionid);


--
-- Name: prestamos prestamos_miembroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_miembroid_fkey FOREIGN KEY (miembroid) REFERENCES public.miembros(miembroid);


--
-- Name: reseña reseña_edicionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_edicionid_fkey" FOREIGN KEY (edicionid) REFERENCES public.ediciones(edicionid);


--
-- Name: reseña reseña_libroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_libroid_fkey" FOREIGN KEY (libroid) REFERENCES public.libros(libroid);


--
-- Name: reseña reseña_miembroid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseña"
    ADD CONSTRAINT "reseña_miembroid_fkey" FOREIGN KEY (miembroid) REFERENCES public.miembros(miembroid);


--
-- Name: subscripciones subscripciones_usuarioid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscripciones
    ADD CONSTRAINT subscripciones_usuarioid_fkey FOREIGN KEY (usuarioid) REFERENCES public.usuario(usuarioid);


--
-- Name: usuario usuario_rolid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_rolid_fkey FOREIGN KEY (rolid) REFERENCES public.roles(rolid);


--
-- PostgreSQL database dump complete
--

