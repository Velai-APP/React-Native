export type BusinessEmailType =
  | "mailbox"
  | "alias"
  | "group";

export interface EmailSetupItem {
  email: string;
  type: BusinessEmailType;
  deliverTo?: string | null;
}

export interface BusinessEmailSetup {
  uid: string;
  businessName: string;
  domain: string;
  provider: "google" | "microsoft";
  emails: EmailSetupItem[];

  status:
    | "awaiting_google_authorization"
    | "google_connected"
    | "provisioning"
    | "completed"
    | "failed";
}