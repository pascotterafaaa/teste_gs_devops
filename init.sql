WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE AT_CLIENTES (
    id_cliente NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    telefone VARCHAR2(20) NOT NULL,
    status VARCHAR2(20) NOT NULL
        CONSTRAINT chk_at_cliente_status CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO')),
    cnpj VARCHAR2(18) NOT NULL UNIQUE,
    email VARCHAR2(120) NOT NULL UNIQUE
);

CREATE TABLE AT_MOTORISTAS (
    id_motorista NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    telefone VARCHAR2(20) NOT NULL,
    status VARCHAR2(20) NOT NULL
        CONSTRAINT chk_at_motorista_status CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO')),
    cpf VARCHAR2(14) NOT NULL UNIQUE,
    cnh VARCHAR2(11) NOT NULL UNIQUE
);

CREATE TABLE AT_VEICULOS (
    id_veiculo NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa VARCHAR2(7) NOT NULL UNIQUE,
    modelo VARCHAR2(80) NOT NULL,
    marca VARCHAR2(60) NOT NULL,
    ano NUMBER(4) NOT NULL,
    status VARCHAR2(20) NOT NULL
        CONSTRAINT chk_at_veiculo_status CHECK (status IN ('DISPONIVEL', 'EM_MANUTENCAO', 'EM_VIAGEM', 'INATIVO'))
);

CREATE TABLE AT_VIAGENS (
    id_viagem NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente NUMBER NOT NULL,
    id_motorista NUMBER NOT NULL,
    id_veiculo NUMBER NOT NULL,
    origem VARCHAR2(120) NOT NULL,
    destino VARCHAR2(120) NOT NULL,
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP,
    status VARCHAR2(20) NOT NULL
        CONSTRAINT chk_at_viagem_status CHECK (status IN ('AGENDADA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA')),
    quilometragem_total NUMBER(12,2) NOT NULL,
    CONSTRAINT fk_at_viagem_cliente FOREIGN KEY (id_cliente) REFERENCES AT_CLIENTES(id_cliente),
    CONSTRAINT fk_at_viagem_motorista FOREIGN KEY (id_motorista) REFERENCES AT_MOTORISTAS(id_motorista),
    CONSTRAINT fk_at_viagem_veiculo FOREIGN KEY (id_veiculo) REFERENCES AT_VEICULOS(id_veiculo)
);

CREATE TABLE AT_CHECKPOINTS (
    id_checkpoint NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_viagem NUMBER NOT NULL,
    latitude NUMBER(10,7) NOT NULL,
    longitude NUMBER(10,7) NOT NULL,
    data_registro TIMESTAMP NOT NULL,
    botao_panico NUMBER(1) DEFAULT 0 NOT NULL
        CONSTRAINT chk_at_checkpoint_panico CHECK (botao_panico IN (0, 1)),
    porta_aberta NUMBER(1) DEFAULT 0 NOT NULL
        CONSTRAINT chk_at_checkpoint_porta CHECK (porta_aberta IN (0, 1)),
    CONSTRAINT fk_at_checkpoint_viagem FOREIGN KEY (id_viagem) REFERENCES AT_VIAGENS(id_viagem) ON DELETE CASCADE
);

CREATE TABLE AT_USUARIOS_SISTEMA (
    usuario VARCHAR2(60) NOT NULL,
    email VARCHAR2(120) NOT NULL,
    senha VARCHAR2(255) NOT NULL,
    status VARCHAR2(20) NOT NULL
        CONSTRAINT chk_at_usuario_status CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO')),
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT pk_at_usuarios_sistema PRIMARY KEY (usuario, email)
);

CREATE INDEX idx_at_viagens_cliente ON AT_VIAGENS(id_cliente);
CREATE INDEX idx_at_viagens_motorista ON AT_VIAGENS(id_motorista);
CREATE INDEX idx_at_viagens_veiculo ON AT_VIAGENS(id_veiculo);
CREATE INDEX idx_at_checkpoints_viagem ON AT_CHECKPOINTS(id_viagem);

EXIT;
