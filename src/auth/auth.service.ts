import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  InternalServerErrorException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(private readonly db: DatabaseService) {}

  async registrar(dto: RegisterDto) {
    // 1. Verificar si el correo ya existe
    const usuarioExistente = await this.db.query(
      'SELECT id_usuario FROM usuario WHERE correo_electronico = ?',
      [dto.correo_electronico],
    );

    if (Array.isArray(usuarioExistente) && usuarioExistente.length > 0) {
      throw new ConflictException('El correo electrónico ya está registrado');
    }

    // 2. Hashear la contraseña con sal (10 rondas de salting)
    const saltRounds = 10;
    const contrasenaHash = await bcrypt.hash(dto.contrasena, saltRounds);

    // 3. Insertar usuario (id_rol_usuario 1 = 'Ciudadano')
    const sql = `
      INSERT INTO usuario (nombre_usuario, correo_electronico, contrasena_hash, id_rol_usuario)
      VALUES (?, ?, ?, 1)
    `;

    try {
      const resultado: any = await this.db.query(sql, [
        dto.nombre_usuario,
        dto.correo_electronico,
        contrasenaHash,
      ]);

      return {
        mensaje: 'Usuario registrado exitosamente',
        id_usuario: resultado.insertId,
        nombre_usuario: dto.nombre_usuario,
        correo_electronico: dto.correo_electronico,
        rol: 'Ciudadano',
      };
    } catch (error) {
      throw new InternalServerErrorException('Error al registrar usuario');
    }
  }

  async login(dto: LoginDto) {
    // 1. Buscar al usuario y su rol
    const sql = `
      SELECT u.id_usuario, u.nombre_usuario, u.correo_electronico, u.contrasena_hash, u.activo, r.nombre_rol
      FROM usuario u
      INNER JOIN cat_rol_usuario r ON u.id_rol_usuario = r.id_rol_usuario
      WHERE u.correo_electronico = ?
    `;

    const usuarios: any = await this.db.query(sql, [dto.correo_electronico]);

    if (!Array.isArray(usuarios) || usuarios.length === 0) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const usuario = usuarios[0];

    if (!usuario.activo) {
      throw new UnauthorizedException('Tu cuenta se encuentra inactiva');
    }

    // 2. Comparar la contraseña con el hash guardado
    const coincide = await bcrypt.compare(dto.contrasena, usuario.contrasena_hash);
    if (!coincide) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // 3. Retornar sesión exitosa
    return {
      mensaje: 'Inicio de sesión exitoso',
      usuario: {
        id_usuario: usuario.id_usuario,
        nombre_usuario: usuario.nombre_usuario,
        correo_electronico: usuario.correo_electronico,
        rol: usuario.nombre_rol,
      },
    };
  }
}