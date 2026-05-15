USE EcommerceFaculdade;
GO

CREATE TABLE enderecos (
    id_endereco INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    rua VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(10) NOT NULL,

    FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente)
);
GO

CREATE TABLE categorias (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
);
GO


USE EcommerceFaculdade;
GO

CREATE TABLE produtos (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    id_categoria INT NOT NULL,

    FOREIGN KEY (id_categoria)
    REFERENCES categorias(id_categoria)
);
GO

CREATE TABLE pedidos (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_endereco INT NOT NULL,
    data_pedido DATE DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL,
    metodo_pagamento VARCHAR(20) NOT NULL,

    FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_endereco)
    REFERENCES enderecos(id_endereco)
);
GO

CREATE TABLE itens_pedido (
    id_item INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),

    FOREIGN KEY (id_pedido)
    REFERENCES pedidos(id_pedido),

    FOREIGN KEY (id_produto)
    REFERENCES produtos(id_produto)
);
GO

CREATE TABLE pagamentos (
    id_pagamento INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    status_pagamento VARCHAR(20) NOT NULL
    CHECK (status_pagamento IN ('Aprovado','Recusado','Pendente')),

    FOREIGN KEY (id_pedido)
    REFERENCES pedidos(id_pedido)
);
GO

INSERT INTO categorias (nome_categoria)
VALUES 
('Eletrônicos'),
('Moda'),
('Casa');
GO

INSERT INTO produtos (nome_produto, preco, id_categoria)
VALUES
('Notebook', 3500.00, 1),
('Mouse', 120.00, 1),
('Camiseta', 79.90, 2),
('Tênis', 299.90, 2),
('Panela', 150.00, 3),
('Liquidificador', 220.00, 3);
GO

INSERT INTO clientes (nome, email, telefone)
VALUES
('Ana Souza','ana@email.com','11999990001'),
('Carlos Lima','carlos@email.com','11999990002'),
('Mariana Silva','mariana@email.com','11999990003'),
('João Costa','joao@email.com','11999990004');
GO

SELECT * FROM clientes;

SELECT * FROM categorias;

SELECT * FROM produtos;

SELECT * FROM enderecos;

INSERT INTO pedidos
(id_cliente, id_endereco, status, metodo_pagamento)
VALUES
(1,1,'Em processamento','PIX'),
(2,2,'Em processamento','Cartão'),
(3,3,'Em processamento','Boleto'),
(1,1,'Em processamento','PIX'),
(4,4,'Em processamento','Cartão');
GO

INSERT INTO enderecos
(id_cliente, rua, numero, cidade, estado, cep)
VALUES
(1,'Rua A','100','São Paulo','SP','01000-000'),
(2,'Rua B','200','Rio de Janeiro','RJ','20000-000'),
(3,'Rua C','300','Belo Horizonte','MG','30000-000'),
(4,'Rua D','400','Curitiba','PR','80000-000');
GO

INSERT INTO itens_pedido
(id_pedido, id_produto, quantidade)
VALUES
(1,1,1),
(1,2,2),

(2,3,2),
(2,4,1),

(3,5,1),

(4,6,1),
(4,2,1),

(5,1,1),
(5,3,3);
GO

SELECT * FROM pedidos;

SELECT * FROM produtos;


INSERT INTO itens_pedido
(id_pedido, id_produto, quantidade)
VALUES
(2,1,1),
(2,2,2),

(3,3,2),
(3,4,1),

(4,5,1),

(5,6,1),
(5,2,1),

(6,1,1),
(6,3,3);
GO

INSERT INTO pagamentos
(id_pedido, status_pagamento)
VALUES
(2,'Aprovado'),
(3,'Aprovado'),
(4,'Pendente'),
(5,'Recusado'),
(6,'Aprovado');
GO

UPDATE pedidos
SET status = 'Aprovado'
WHERE id_pedido IN (2,3,6);

UPDATE pedidos
SET status = 'Pendente'
WHERE id_pedido = 4;

UPDATE pedidos
SET status = 'Recusado'
WHERE id_pedido = 5;
GO

SELECT * FROM pedidos;

DELETE FROM clientes
WHERE id_cliente = 1;

SELECT 
    c.nome,
    p.id_pedido,
    p.data_pedido,
    SUM(i.quantidade * pr.preco) AS total_pedido
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN itens_pedido i ON p.id_pedido = i.id_pedido
JOIN produtos pr ON i.id_produto = pr.id_produto
GROUP BY c.nome, p.id_pedido, p.data_pedido

SELECT 
    pr.nome_produto,
    SUM(i.quantidade) AS total_vendido
FROM itens_pedido i
JOIN produtos pr ON i.id_produto = pr.id_produto
GROUP BY pr.nome_produto
ORDER BY total_vendido DESC;

SELECT 
    cat.nome_categoria,
    SUM(i.quantidade * pr.preco) AS faturamento
FROM itens_pedido i
JOIN produtos pr ON i.id_produto = pr.id_produto
JOIN categorias cat ON pr.id_categoria = cat.id_categoria
GROUP BY cat.nome_categoria;

SELECT 
    p.id_pedido,
    pg.status_pagamento
FROM pedidos p
JOIN pagamentos pg 
ON p.id_pedido = pg.id_pedido
WHERE pg.status_pagamento = 'Pendente';

SELECT 
    p.id_pedido,
    SUM(i.quantidade * pr.preco) AS total_pedido
FROM pedidos p
JOIN itens_pedido i 
ON p.id_pedido = i.id_pedido
JOIN produtos pr 
ON i.id_produto = pr.id_produto
GROUP BY p.id_pedido;

SELECT 
    c.nome,
    COUNT(p.id_pedido) AS total_compras
FROM clientes c
JOIN pedidos p 
ON c.id_cliente = p.id_cliente
GROUP BY c.nome
HAVING COUNT(p.id_pedido) > 3;

SELECT 
    p.id_pedido,
    SUM(i.quantidade * pr.preco) AS total,

    CASE
        WHEN SUM(i.quantidade * pr.preco) > 2000 THEN 'Alta'
        WHEN SUM(i.quantidade * pr.preco) > 500 THEN 'Média'
        ELSE 'Baixa'
    END AS prioridade

FROM pedidos p
JOIN itens_pedido i 
ON p.id_pedido = i.id_pedido
JOIN produtos pr 
ON i.id_produto = pr.id_produto

GROUP BY p.id_pedido;

SELECT 
    pr.nome_produto
FROM produtos pr
LEFT JOIN itens_pedido i
ON pr.id_produto = i.id_produto
WHERE i.id_produto IS NULL;

SELECT TOP 2 *
FROM (

    SELECT 
        c.nome,
        SUM(i.quantidade * pr.preco) AS total_gasto

    FROM clientes c
    JOIN pedidos p 
    ON c.id_cliente = p.id_cliente

    JOIN itens_pedido i
    ON p.id_pedido = i.id_pedido

    JOIN produtos pr
    ON i.id_produto = pr.id_produto

    GROUP BY c.nome

) AS ranking

ORDER BY total_gasto DESC;

SELECT 
    id_pedido,
    status_pagamento
FROM pagamentos
WHERE status_pagamento = 'Aprovado'

UNION

SELECT 
    id_pedido,
    status_pagamento
FROM pagamentos
WHERE status_pagamento = 'Pendente';