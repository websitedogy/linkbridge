export type ApiMeta = {
  current_page: number;
  per_page: number;
  total: number;
  last_page: number;
};

export type ApiSuccess<T> = {
  success: true;
  message: string;
  data: T;
  meta?: ApiMeta;
};

export type User = {
  id: string;
  name: string;
  email: string;
  mobile: string | null;
  role: "BUYER" | "SELLER" | "ADMIN" | "SUPER_ADMIN";
  status: string;
  email_verified_at: string | null;
  mobile_verified_at: string | null;
};

export type Industry = { id: string; name: string; slug: string };
export type Category = { id: string; industry_id: string; name: string; slug: string };
export type Location = {
  id: string;
  parent_id: string | null;
  type: string;
  name: string;
  slug: string;
  country_code: string | null;
};

export type ListingCompany = {
  id: string | null;
  public_name: string | null;
  company_name?: string | null;
  slug: string | null;
  industry: string | null;
  industry_slug: string | null;
  category: string | null;
  category_slug: string | null;
  country: string | null;
  state: string | null;
  city: string | null;
  founded_year: number | null;
  employee_count: number | null;
  business_type: string | null;
  website?: string | null;
  description: string | null;
};

export type Listing = {
  id: string;
  title: string;
  slug: string;
  short_description: string;
  description: string | null;
  asking_price: number | null;
  currency: string;
  revenue_min: number | null;
  revenue_max: number | null;
  profit_min: number | null;
  profit_max: number | null;
  employee_min: number | null;
  employee_max: number | null;
  listing_type: string | null;
  visibility: string;
  status: string | null;
  published_at: string | null;
  company: ListingCompany;
  media?: ListingMedia[];
};

export type ListingMedia = {
  id: string;
  file_type: string;
  file_name: string;
  mime_type: string;
  file_size: number;
  sort_order: number;
  is_primary: boolean;
  url: string | null;
};

export type Company = {
  id: string;
  company_name: string;
  public_name: string;
  slug: string;
  industry_id: string;
  category_id: string;
  industry: string | null;
  category: string | null;
  location_id: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  employee_count: number | null;
  business_type: string | null;
  description: string | null;
  status: string;
  verification_status: string;
};

export type Interest = {
  id: string;
  listing_id: string;
  message: string | null;
  status: string;
  created_at: string;
  listing?: Listing;
  buyer?: { id: string; name: string };
};

export type Inquiry = {
  id: string;
  subject: string;
  message: string;
  status: string;
  created_at: string;
  listing?: Listing;
};
