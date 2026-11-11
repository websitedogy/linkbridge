import { apiRequest, authRequest } from "@/lib/api/client";
import type {
  Category,
  Company,
  Industry,
  Inquiry,
  Interest,
  Listing,
  Location,
  User,
} from "@/lib/types/marketplace";

export const marketplace = {
  me: () => authRequest<User>("me").then((response) => response.data),
  login: (body: { email: string; password: string }) =>
    authRequest<{ user: User }>("login", body).then((response) => response.data.user),
  register: (body: {
    name: string;
    email: string;
    password: string;
    password_confirmation: string;
    role: "buyer" | "seller";
    mobile?: string;
  }) => authRequest<{ user: User }>("register", body).then((response) => response.data.user),
  logout: () => authRequest<null>("logout"),
  industries: () => apiRequest<Industry[]>("/industries").then((response) => response.data),
  categories: () => apiRequest<Category[]>("/categories").then((response) => response.data),
  locations: (type: string) =>
    apiRequest<Location[]>(`/locations?type=${type}`).then((response) => response.data),
  listings: (query: string) =>
    apiRequest<Listing[]>(`/listings${query}`).then((response) => response),
  listing: (slug: string) => apiRequest<Listing>(`/listings/${slug}`).then((response) => response.data),
  companies: () => apiRequest<Company[]>("/seller/companies").then((response) => response.data),
  createCompany: (body: Record<string, unknown>) =>
    apiRequest<Company>("/seller/companies", { method: "POST", body }).then((response) => response.data),
  sellerListings: () => apiRequest<Listing[]>("/seller/listings"),
  sellerListing: (id: string) =>
    apiRequest<Listing>(`/seller/listings/${id}`).then((response) => response.data),
  createListing: (body: Record<string, unknown>) =>
    apiRequest<Listing>("/seller/listings", { method: "POST", body }).then((response) => response.data),
  updateListing: (id: string, body: Record<string, unknown>) =>
    apiRequest<Listing>(`/seller/listings/${id}`, { method: "PUT", body }).then((response) => response.data),
  submitListing: (id: string) =>
    apiRequest<Listing>(`/seller/listings/${id}/submit`, { method: "POST" }).then((response) => response.data),
  uploadMedia: (id: string, file: File) => {
    const formData = new FormData();
    formData.set("file", file);
    return apiRequest<Listing>(`/seller/listings/${id}/media`, { method: "POST", formData }).then(
      (response) => response.data,
    );
  },
  favorites: () => apiRequest<Listing[]>("/buyer/favorites").then((response) => response.data),
  favorite: (id: string) => apiRequest<null>(`/buyer/favorites/${id}`, { method: "POST" }),
  unfavorite: (id: string) => apiRequest<null>(`/buyer/favorites/${id}`, { method: "DELETE" }),
  interests: () => apiRequest<Interest[]>("/buyer/interests").then((response) => response.data),
  expressInterest: (id: string, message: string) =>
    apiRequest<Interest>(`/buyer/listings/${id}/interest`, { method: "POST", body: { message } }).then(
      (response) => response.data,
    ),
  sellerInterests: () => apiRequest<Interest[]>("/seller/interests").then((response) => response.data),
  updateInterest: (id: string, status: string) =>
    apiRequest<Interest>(`/seller/interests/${id}`, { method: "PATCH", body: { status } }).then(
      (response) => response.data,
    ),
  inquire: (id: string, subject: string, message: string) =>
    apiRequest<Inquiry>(`/buyer/listings/${id}/inquiry`, {
      method: "POST",
      body: { subject, message },
    }),
  sellerInquiries: () => apiRequest<Inquiry[]>("/seller/inquiries").then((response) => response.data),
};
