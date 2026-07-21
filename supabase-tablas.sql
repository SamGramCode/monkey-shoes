-- MONKEY SHOES — Tablas Supabase
-- Ejecutar en: https://supabase.com → SQL Editor

-- 1. Productos
create table if not exists productos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  marca text,
  descripcion text,
  precio numeric(12,2) not null default 0,
  moneda text default 'CLP',
  fotos jsonb default '[]',
  activo boolean default true,
  created_at timestamptz default now()
);

-- 2. Variantes (talla + color + stock)
create table if not exists variantes (
  id uuid primary key default gen_random_uuid(),
  producto_id uuid references productos(id) on delete cascade,
  talla text not null,
  color text,
  stock int default 0,
  created_at timestamptz default now()
);

-- 3. Pedidos
create table if not exists pedidos (
  id uuid primary key default gen_random_uuid(),
  cliente_nombre text not null,
  cedula text,
  telefono text,
  pais text check (pais in ('venezuela','chile')),
  ciudad text,
  direccion text,
  notas text,
  total numeric(12,2),
  estado text default 'pendiente' check (estado in ('pendiente','confirmado','enviado','entregado','cancelado')),
  created_at timestamptz default now()
);

-- 4. Items del pedido
create table if not exists pedido_items (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid references pedidos(id) on delete cascade,
  producto_id uuid references productos(id),
  talla text,
  color text,
  cantidad int default 1,
  precio_unitario numeric(12,2),
  created_at timestamptz default now()
);

-- RLS (Row Level Security)
alter table productos enable row level security;
alter table variantes enable row level security;
alter table pedidos enable row level security;
alter table pedido_items enable row level security;

-- Políticas: clientes pueden leer productos/variantes y crear pedidos
create policy "productos_public_read" on productos for select using (activo = true);
create policy "variantes_public_read" on variantes for select using (true);
create policy "pedidos_insert" on pedidos for insert with check (true);
create policy "pedido_items_insert" on pedido_items for insert with check (true);

-- Admin puede hacer todo (se configura con service role en admin.html)
create policy "admin_productos" on productos for all using (true);
create policy "admin_variantes" on variantes for all using (true);
create policy "admin_pedidos_read" on pedidos for select using (true);
create policy "admin_pedido_items_read" on pedido_items for select using (true);
