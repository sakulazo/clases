export interface Asignatura {
  nombre: string
  descripcion: string
  /** Nombre del icono de Lucide (ver src/components/Icon.astro) */
  icono: string
}

export interface Nivel {
  id: string
  label: string
  descripcion: string
  asignaturas: Asignatura[]
  horarios: {
    dias: string[]
    horas: string[]
  }
  precio: string
}

export interface Especialidad {
  nombre: string
  /** Nombre del icono de Lucide (ver src/components/Icon.astro) */
  icono: string
  color: string
  descripcion: string
}

export const niveles: Nivel[] = [
  {
    id: 'eso',
    label: 'ESO',
    descripcion: 'Educación Secundaria Obligatoria',
    asignaturas: [
      { nombre: 'Matemáticas', descripcion: 'Álgebra, geometría, estadística y probabilidad', icono: 'ruler' },
      { nombre: 'Física', descripcion: 'Mecánica, electricidad, ondas y termodinámica', icono: 'zap' },
      { nombre: 'Química', descripcion: 'Estequiometría, enlaces, reacciones y formulación', icono: 'flask-conical' }
    ],
    horarios: {
      dias: ['Lunes', 'Miércoles', 'Viernes'],
      horas: ['16:00', '17:00', '18:00']
    },
    precio: '15€/h'
  },
  {
    id: 'bachillerato',
    label: 'Bachillerato',
    descripcion: 'Bachillerato de Ciencias y Tecnología',
    asignaturas: [
      { nombre: 'Matemáticas I', descripcion: 'Álgebra lineal, análisis y geometría analítica', icono: 'ruler' },
      { nombre: 'Matemáticas II', descripcion: 'Cálculo integral, probabilidad y estadística avanzada', icono: 'chart-column' },
      { nombre: 'Física', descripcion: 'Mecánica avanzada, electromagnetismo y óptica', icono: 'zap' },
      { nombre: 'Química', descripcion: 'Química orgánica, termoquímica y equilibrio químico', icono: 'flask-conical' }
    ],
    horarios: {
      dias: ['Martes', 'Jueves'],
      horas: ['17:00', '18:00', '19:00']
    },
    precio: '18€/h'
  },
  {
    id: 'cfgs',
    label: 'CFGS Administración y Finanzas',
    descripcion: 'Ciclo Formativo de Grado Superior',
    asignaturas: [
      { nombre: 'Matemáticas Financieras', descripcion: 'Capitalización, descuento, rentas y préstamos', icono: 'coins' },
      { nombre: 'Contabilidad', descripcion: 'Contabilidad financiera, PGC y análisis de balances', icono: 'clipboard-list' },
      { nombre: 'Fiscalidad', descripcion: 'IRPF, IVA, Impuesto de Sociedades', icono: 'file-text' }
    ],
    horarios: {
      dias: ['Sábado'],
      horas: ['10:00', '11:00', '12:00']
    },
    precio: '20€/h'
  }
]

export const especialidades: Especialidad[] = [
  {
    nombre: 'Matemáticas',
    icono: 'ruler',
    color: 'blue',
    descripcion: 'Especialista en matemáticas con experiencia en todos los niveles educativos'
  },
  {
    nombre: 'Física',
    icono: 'zap',
    color: 'purple',
    descripcion: 'Apasionada de la física con enfoque práctico y cercano'
  },
  {
    nombre: 'Química',
    icono: 'flask-conical',
    color: 'green',
    descripcion: 'Experta en química con métodos didácticos innovadores'
  }
]

export const profesor = {
  nombre: 'Marcos Sánchez',
  titulo: 'Técnico Superior en Administración y Finanzas',
  experiencia: 'Más de 10 años',
  bio: 'Más de 10 años de experiencia ayudando a estudiantes de ESO, Bachillerato y CFGS a aprobar matemáticas, física y química. Más del 95% de aprobados.',
  modalidad: 'Clases presenciales a domicilio en El Ejido'
}
