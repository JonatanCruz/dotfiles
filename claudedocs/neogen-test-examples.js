// ============================================================================
// NEOGEN TEST EXAMPLES
// ============================================================================
// Archivo de prueba para testing de Neogen
// Testing: Coloca cursor en cada función y presiona <leader>nf
// ============================================================================

// TEST 1: Función simple
// Cursor aquí ↓ y presionar <leader>nf
function add(a, b) {
  return a + b;
}

// TEST 2: Función con múltiples parámetros
// Cursor aquí ↓ y presionar <leader>nf
function calculateTotal(price, tax, discount, shippingCost) {
  const subtotal = price * (1 + tax);
  const total = subtotal - discount + shippingCost;
  return total;
}

// TEST 3: Función asíncrona
// Cursor aquí ↓ y presionar <leader>nf
async function fetchUserData(userId, includeProfile = false) {
  const response = await fetch(`/api/users/${userId}`);
  const data = await response.json();

  if (includeProfile) {
    const profile = await fetch(`/api/profiles/${userId}`);
    data.profile = await profile.json();
  }

  return data;
}

// TEST 4: Arrow function
// Cursor aquí ↓ y presionar <leader>nf
const multiply = (x, y) => x * y;

// TEST 5: Función con destructuring
// Cursor aquí ↓ y presionar <leader>nf
function processUser({ name, email, age }, options = {}) {
  const { verbose = false, validateEmail = true } = options;

  if (validateEmail && !email.includes('@')) {
    throw new Error('Invalid email');
  }

  return { name, email, age, processed: true };
}

// TEST 6: Clase
// Cursor aquí ↓ y presionar <leader>nc
class UserService {
  constructor(apiUrl, timeout = 5000) {
    this.apiUrl = apiUrl;
    this.timeout = timeout;
  }

  async getUser(id) {
    const response = await fetch(`${this.apiUrl}/users/${id}`);
    return response.json();
  }

  async updateUser(id, data) {
    const response = await fetch(`${this.apiUrl}/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
    return response.json();
  }
}

// TEST 7: Generics (en TypeScript cambiar extensión a .ts)
// Cursor aquí ↓ y presionar <leader>nf
function findById(items, id) {
  return items.find(item => item.id === id);
}

// TEST 8: Función con callback
// Cursor aquí ↓ y presionar <leader>nf
function processItems(items, callback, errorHandler) {
  try {
    const results = items.map(callback);
    return results;
  } catch (error) {
    if (errorHandler) {
      errorHandler(error);
    }
    throw error;
  }
}

// TEST 9: Auto-detección
// Cursor aquí ↓ y presionar <leader>ng (auto-detect)
function autoDetectTest(param1, param2) {
  return { param1, param2 };
}

// TEST 10: Documentación de archivo completo
// Ir a línea 1 y presionar <leader>nF (File docs)

// ============================================================================
// VERIFICACIÓN DE RESULTADO ESPERADO
// ============================================================================
// Después de presionar <leader>nf, deberías ver:
//
// /**
//  * [TODO: description]
//  * @param {*} a - [TODO: parameter]
//  * @param {*} b - [TODO: parameter]
//  * @returns {*} [TODO: return value]
//  */
// function add(a, b) {
//   return a + b;
// }
//
// Navega con Tab entre [TODO: ...] placeholders
// Completa la información y presiona Enter para salir
// ============================================================================
