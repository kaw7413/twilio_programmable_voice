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

  getAccessToken(identity: string, platform: string): string {
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
      pushCredentialSid: this.configService.get<string>((platform == "android") ?
        'TWILIO_PUSH_CRENDENTIAL_SID' : 'TWILIO_PUSH_CRENDENTIAL_SID_APN',
      ),
      incomingAllow: true,
    });

    token.addGrant(voiceGrant);

    console.log(token);

    return token.toJwt();
  }
}
