import { Request } from 'express';
import { admin } from 'src/auth/firebase-admin';
import { DatabaseService } from './database.service';
import { Controller, Get, Post, Patch, Delete, Query, Body, Req } from '@nestjs/common';

@Controller('database')
export class DatabaseController {
    constructor(private readonly databaseService: DatabaseService) { }

    @Get('read')
    async read(@Query('path') path: string, @Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        const fullPath = `users/${uid}/${path}`;
        const data = await this.databaseService.read(fullPath);
        return { data };
    }

    @Post('write')
    async write(@Body() body: { path: string; data: any }, @Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        const fullPath = `users/${uid}/${body.path}`;
        await this.databaseService.write(fullPath, body.data);
        return { success: true };
    }

    @Patch('update')
    async update(@Body() body: { path: string; data: any }, @Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        const fullPath = `users/${uid}/${body.path}`;
        await this.databaseService.update(fullPath, body.data);
        return { success: true };
    }

    @Delete('delete')
    async delete(@Query('path') path: string, @Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        const fullPath = `users/${uid}/${path}`;
        await this.databaseService.delete(fullPath);
        return { success: true };
    }
}
