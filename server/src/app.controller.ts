import { Controller, Get, Param, Req } from '@nestjs/common';
import { AppService } from './app.service';
import { Request } from 'express';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('/accessToken/:identity')
  getAccessToken(
    @Param('identity') identity: string,
    @Req() request: Request,
  ): string {
    console.log('Request headers', request.headers);
    return this.appService.getAccessToken(identity);
  }
}
