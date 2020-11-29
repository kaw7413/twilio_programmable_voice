import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as twilio from 'twilio';

@Injectable()
export class AppService {
  private twilioApp: twilio.Twilio;

  constructor(private configService: ConfigService) {
    this.twilioApp = twilio(
      this.configService.get<string>('TWILIO_ACCOUNT_SID'),
      this.configService.get<string>('TWILIO_AUTH_TOKEN'),
    );
  }

  getAccessToken(identity: string): string {
    const token = new twilio.jwt.AccessToken(
      this.configService.get<string>('TWILIO_ACCOUNT_SID'),
      this.configService.get<string>('TWILIO_API_KEY'),
      this.configService.get<string>('TWILIO_API_SECRET'),
      { identity },
    );

    const voiceGrant = new twilio.jwt.AccessToken.VoiceGrant({
      outgoingApplicationSid: this.configService.get<string>(
        'TWILIO_OUTGOING_APPLICATION_SID',
      ),
      pushCredentialSid: this.configService.get<string>(
        'TWILIO_PUSH_CRENDENTIAL_SID',
      ),
      incomingAllow: true,
    });

    token.addGrant(voiceGrant);

    return token.toJwt();
  }
}
