# Refactoring.nvim - Ejemplos Prácticos

## TypeScript/JavaScript Examples

### Extract Function
**Antes:**
```typescript
function processData(items: Item[]) {
  // Seleccionar estas 3 líneas en visual mode
  const filtered = items.filter(item => item.active);
  const mapped = filtered.map(item => item.value);
  const sum = mapped.reduce((acc, val) => acc + val, 0);

  return sum;
}
```

**Acción:** Seleccionar líneas → `<leader>re` → Nombre: "calculateSum"

**Después:**
```typescript
function calculateSum(items: Item[]) {
  const filtered = items.filter(item => item.active);
  const mapped = filtered.map(item => item.value);
  return mapped.reduce((acc, val) => acc + val, 0);
}

function processData(items: Item[]) {
  const sum = calculateSum(items);
  return sum;
}
```

### Extract Variable
**Antes:**
```javascript
const result = users.filter(u => u.age > 18 && u.verified && u.country === 'US');
```

**Acción:** Seleccionar expresión compleja → `<leader>rv` → Nombre: "adultVerifiedUSUsers"

**Después:**
```javascript
const adultVerifiedUSUsers = u => u.age > 18 && u.verified && u.country === 'US';
const result = users.filter(adultVerifiedUSUsers);
```

### Inline Variable
**Antes:**
```typescript
const maxRetries = 3;
const config = {
  retries: maxRetries,
  timeout: 5000,
};
```

**Acción:** Cursor en `maxRetries` → `<leader>ri`

**Después:**
```typescript
const config = {
  retries: 3,
  timeout: 5000,
};
```

## Python Examples

### Extract Function
**Antes:**
```python
def analyze_data(data):
    # Seleccionar este bloque
    cleaned = [x for x in data if x is not None]
    normalized = [x / max(cleaned) for x in cleaned]
    averaged = sum(normalized) / len(normalized)

    return averaged
```

**Acción:** Seleccionar líneas → `<leader>re` → Nombre: "normalize_and_average"

**Después:**
```python
def normalize_and_average(data):
    cleaned = [x for x in data if x is not None]
    normalized = [x / max(cleaned) for x in cleaned]
    return sum(normalized) / len(normalized)

def analyze_data(data):
    return normalize_and_average(data)
```

### Debug Print Variable
**Antes:**
```python
def process_user(user_data):
    transformed = transform(user_data)
    validated = validate(transformed)
    return validated
```

**Acción:** Cursor en `transformed` → `<leader>rd`

**Después:**
```python
def process_user(user_data):
    transformed = transform(user_data)
    print(f"transformed: {transformed}")
    validated = validate(transformed)
    return validated
```

**Cleanup:** `<leader>rc` para remover todos los prints

## Lua Examples

### Extract Function
**Antes:**
```lua
local function init_config()
  -- Seleccionar este bloque
  local defaults = {
    timeout = 5000,
    retries = 3,
  }
  local merged = vim.tbl_deep_extend("force", defaults, user_opts)
  return merged
end
```

**Acción:** Seleccionar líneas → `<leader>re` → Nombre: "merge_config"

**Después:**
```lua
local function merge_config(user_opts)
  local defaults = {
    timeout = 5000,
    retries = 3,
  }
  return vim.tbl_deep_extend("force", defaults, user_opts)
end

local function init_config()
  return merge_config()
end
```

## Workflow Completo

### Ejemplo: Refactorizar función compleja

**Paso 1: Código original (complejo)**
```typescript
function processOrder(order: Order, customer: Customer) {
  // Validación
  if (!order.items || order.items.length === 0) {
    throw new Error("Empty order");
  }
  if (!customer.verified) {
    throw new Error("Unverified customer");
  }

  // Cálculo
  const subtotal = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;
  const shipping = subtotal > 100 ? 0 : 10;
  const total = subtotal + tax + shipping;

  // Descuentos
  let discount = 0;
  if (customer.loyalty === 'gold') {
    discount = total * 0.1;
  } else if (customer.loyalty === 'silver') {
    discount = total * 0.05;
  }

  const finalTotal = total - discount;

  return {
    subtotal,
    tax,
    shipping,
    discount,
    total: finalTotal,
  };
}
```

**Paso 2: Extract validation → `<leader>re` → "validateOrder"**
```typescript
function validateOrder(order: Order, customer: Customer) {
  if (!order.items || order.items.length === 0) {
    throw new Error("Empty order");
  }
  if (!customer.verified) {
    throw new Error("Unverified customer");
  }
}
```

**Paso 3: Extract calculation → `<leader>re` → "calculateOrderTotals"**
```typescript
function calculateOrderTotals(order: Order) {
  const subtotal = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;
  const shipping = subtotal > 100 ? 0 : 10;
  return { subtotal, tax, shipping, total: subtotal + tax + shipping };
}
```

**Paso 4: Extract discount logic → `<leader>re` → "calculateDiscount"**
```typescript
function calculateDiscount(total: number, loyaltyTier: string) {
  if (loyaltyTier === 'gold') {
    return total * 0.1;
  } else if (loyaltyTier === 'silver') {
    return total * 0.05;
  }
  return 0;
}
```

**Paso 5: Resultado final (limpio y modular)**
```typescript
function processOrder(order: Order, customer: Customer) {
  validateOrder(order, customer);

  const { subtotal, tax, shipping, total } = calculateOrderTotals(order);
  const discount = calculateDiscount(total, customer.loyalty);
  const finalTotal = total - discount;

  return {
    subtotal,
    tax,
    shipping,
    discount,
    total: finalTotal,
  };
}
```

## Telescope Selector Workflow

**Uso del selector visual:**
```
1. Seleccionar código en visual mode (v o V)
2. Presionar <leader>rs
3. Telescope muestra opciones disponibles:
   ┌─────────────────────────────────────┐
   │ > Extract Function                  │
   │   Extract Function To File          │
   │   Extract Variable                  │
   │   Inline Variable                   │
   └─────────────────────────────────────┘
4. Navegar con j/k, seleccionar con Enter
5. Seguir prompts (nombre de función/variable)
```

## Casos de Uso Comunes

### 1. Refactorizar código duplicado
- Identificar bloques similares
- Extract function para cada uno
- Reemplazar duplicados con llamadas a función

### 2. Simplificar expresiones complejas
- Identificar expresiones largas o anidadas
- Extract variable con nombre descriptivo
- Mejora legibilidad inmediatamente

### 3. Debugging temporal
- Agregar debug prints con `<leader>rd`
- Investigar valores en runtime
- Cleanup con `<leader>rc` cuando termine

### 4. Preparar código para testing
- Extract functions facilitan unit tests
- Funciones pequeñas = tests más simples
- Mejor coverage y mantenibilidad
