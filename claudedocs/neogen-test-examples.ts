// ============================================================================
// NEOGEN TEST EXAMPLES - TYPESCRIPT
// ============================================================================
// Archivo de prueba para testing de Neogen con TypeScript (TSDoc)
// Testing: Coloca cursor en cada función y presiona <leader>nf
// ============================================================================

// TEST 1: Función tipada simple
// Cursor aquí ↓ y presionar <leader>nf
function calculateArea(width: number, height: number): number {
  return width * height;
}

// TEST 2: Función con tipos genéricos
// Cursor aquí ↓ y presionar <leader>nf
function findById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// TEST 3: Interface
// Cursor aquí ↓ y presionar <leader>nt
interface UserConfig {
  name: string;
  email: string;
  age?: number;
  role: 'admin' | 'user' | 'guest';
  permissions: string[];
}

// TEST 4: Type alias
// Cursor aquí ↓ y presionar <leader>nt
type AsyncResult<T> = {
  data: T | null;
  error: Error | null;
  loading: boolean;
};

// TEST 5: Clase genérica
// Cursor aquí ↓ y presionar <leader>nc
class ApiClient<T> {
  constructor(
    private baseUrl: string,
    private defaultHeaders: Record<string, string> = {}
  ) {}

  async get(endpoint: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      headers: this.defaultHeaders,
    });
    return response.json();
  }

  async post(endpoint: string, data: Partial<T>): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        ...this.defaultHeaders,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    return response.json();
  }
}

// TEST 6: Función con Promise
// Cursor aquí ↓ y presionar <leader>nf
async function fetchWithRetry<T>(
  url: string,
  retries: number = 3,
  delay: number = 1000
): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Max retries exceeded');
}

// TEST 7: Función con Rest parameters
// Cursor aquí ↓ y presionar <leader>nf
function sum(...numbers: number[]): number {
  return numbers.reduce((acc, n) => acc + n, 0);
}

// TEST 8: Función con Optional parameters
// Cursor aquí ↓ y presionar <leader>nf
function createUser(
  name: string,
  email: string,
  age?: number,
  role: 'admin' | 'user' = 'user'
): UserConfig {
  return { name, email, age, role, permissions: [] };
}

// TEST 9: Arrow function tipada
// Cursor aquí ↓ y presionar <leader>nf
const transformData = <T, R>(data: T[], mapper: (item: T) => R): R[] => {
  return data.map(mapper);
};

// TEST 10: Función con Union types
// Cursor aquí ↓ y presionar <leader>nf
function processValue(value: string | number | boolean): string {
  if (typeof value === 'string') return value.toUpperCase();
  if (typeof value === 'number') return value.toFixed(2);
  return value ? 'true' : 'false';
}

// TEST 11: Enum
// Cursor aquí ↓ y presionar <leader>nt
enum Status {
  Pending = 'PENDING',
  Active = 'ACTIVE',
  Completed = 'COMPLETED',
  Failed = 'FAILED',
}

// TEST 12: Namespace
// Cursor aquí ↓ y presionar <leader>nc
namespace Utils {
  export function formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  export function parseDate(dateString: string): Date {
    return new Date(dateString);
  }
}

// TEST 13: Abstract class
// Cursor aquí ↓ y presionar <leader>nc
abstract class BaseRepository<T> {
  constructor(protected tableName: string) {}

  abstract findById(id: string): Promise<T | null>;
  abstract save(entity: T): Promise<T>;
  abstract delete(id: string): Promise<boolean>;

  protected async query<R>(sql: string, params: any[]): Promise<R[]> {
    // Implementation here
    return [];
  }
}

// TEST 14: Función con Readonly parameters
// Cursor aquí ↓ y presionar <leader>nf
function processConfig(config: Readonly<UserConfig>): string {
  return `User: ${config.name} (${config.role})`;
}

// TEST 15: Función con Tuple
// Cursor aquí ↓ y presionar <leader>nf
function parseCoordinates(input: string): [number, number] | null {
  const parts = input.split(',').map(Number);
  if (parts.length !== 2 || parts.some(isNaN)) return null;
  return [parts[0], parts[1]];
}

// ============================================================================
// VERIFICACIÓN DE RESULTADO ESPERADO (TSDOC)
// ============================================================================
// Después de presionar <leader>nf, deberías ver:
//
// /**
//  * [TODO: description]
//  * @param width - [TODO: parameter]
//  * @param height - [TODO: parameter]
//  * @returns [TODO: return value]
//  */
// function calculateArea(width: number, height: number): number {
//   return width * height;
// }
//
// Nota las diferencias con JSDoc:
// - TSDoc usa "- " después de @param (no llaves de tipo)
// - Los tipos ya están en la firma de función (no se duplican)
// ============================================================================
